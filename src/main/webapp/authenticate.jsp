<%--
  ~ Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~ WSO2 Inc. licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file except
  ~ in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~  http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  --%>

<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="org.apache.http.client.methods.CloseableHttpResponse" %>
<%@ page import="org.apache.http.client.methods.HttpPost" %>
<%@ page import="org.apache.http.impl.client.CloseableHttpClient" %>
<%@ page import="org.apache.http.impl.client.HttpClients" %>
<%@ page import="org.apache.http.HttpHeaders" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="java.util.ResourceBundle" %>

<%
    Logger log = Logger.getLogger("org.sample.login.portal.login");
    final String RESPONSE_PARAM_TOKEN = "token";
    String identityServerURL = "https://localhost:9443";
    String authAPIEp = "/api/identity/auth/v1.0/authenticate";
    String commonauthEp = "/commonauth";
    CloseableHttpClient httpClient = HttpClients.createDefault();
    String sessionDataKey = request.getParameter("sessionDataKey");
    String token = "";
    
    try {
        ResourceBundle resource = ResourceBundle.getBundle("loginportal");
        identityServerURL = resource.getString("identity.server.url");
        authAPIEp = resource.getString("auth.api.ep");
        commonauthEp = resource.getString("common.auth.ep");
    } catch (Exception e) {
        log.error("Error while retrieving properties from loginportal.properties", e);
        log.info("Using default property values");
    }
    
    HttpPost httpPostRequest = new HttpPost(identityServerURL + authAPIEp);
    String auth = request.getParameter("username") + ":" + request.getParameter("password");
    byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(StandardCharsets.UTF_8));
    httpPostRequest.setHeader(HttpHeaders.AUTHORIZATION, "Basic " + new String(encodedAuth));
    httpPostRequest.setHeader(HttpHeaders.CONTENT_TYPE, "application/json");
    
    try (CloseableHttpResponse res = httpClient.execute(httpPostRequest)) {
        
        int statusCode = res.getStatusLine().getStatusCode();
        if (statusCode == 200) {
            JSONObject json = new JSONObject(EntityUtils.toString(res.getEntity()));
            token = json.getString(RESPONSE_PARAM_TOKEN);
        }
        EntityUtils.consume(res.getEntity());
    } catch (Exception e) {
        log.error("Error while processing auth request.", e);
    }
    
    String redirectURL = identityServerURL + commonauthEp;
%>


<html>
<head>
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
    <title>Login Portal</title>
</head>
<body style="font-family: 'Roboto', sans-serif;">
<p>You are now redirected to <%=redirectURL%> If the redirection fails, please click the post button.</p>

<form method='post' action='<%=redirectURL%>'>
    <p>
        <input id="token" name="token" type="hidden" value="<%=Encode.forHtmlAttribute(token)%>">
        <input id="sessionDataKey" name="sessionDataKey" type="hidden"
               value="<%=Encode.forHtmlAttribute(sessionDataKey)%>">
        <button type='submit'>POST</button>
    </p>
</form>
<script type='text/javascript'>
    document.forms[0].submit();
</script>

</body>
</html>
