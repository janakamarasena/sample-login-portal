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
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="java.util.Iterator" %>

<%
    Logger log = Logger.getLogger("org.sample.login.portal.authenticate");
    final String RESPONSE_PARAM_TOKEN = "token";
    final String RESPONSE_PARAM_PROPERTIES = "properties";
    final String RESPONSE_PARAM_CODE = "code";
    final String RESPONSE_PARAM_DESCRIPTION = "description";
    String loginDoEp = "login.do";
    String identityServerURL = "https://localhost:9443";
    String authAPIEp = "/api/identity/auth/v1.0/authenticate";
    String commonauthEp = "/commonauth";
    CloseableHttpClient httpClient = HttpClients.createDefault();
    String sessionDataKey = request.getParameter("sessionDataKey");
    String token;
    String redirectURL;
    
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
    JSONObject json = null;
    try (CloseableHttpResponse res = httpClient.execute(httpPostRequest)) {
        
        json = new JSONObject(EntityUtils.toString(res.getEntity()));
        EntityUtils.consume(res.getEntity());
    } catch (Exception e) {
        log.error("Error while processing auth request.", e);
    }
    if (json != null && json.has(RESPONSE_PARAM_TOKEN)) {
        token = json.getString(RESPONSE_PARAM_TOKEN);
        redirectURL = identityServerURL + commonauthEp;
    } else {
        
        // Populate a key value map from the query string received.
        Map<String, String> queryParamMap = new HashMap<String, String>();
        String queryString = request.getQueryString();
        if (StringUtils.isNotBlank(queryString)) {
            StringTokenizer stringTokenizer = new StringTokenizer(queryString, "&");
            while (stringTokenizer.hasMoreTokens()) {
                String queryParam = stringTokenizer.nextToken();
                String[] queryParamKeyValueArray = queryParam.split("=", 2);
                queryParamMap.put(queryParamKeyValueArray[0], queryParamKeyValueArray[1]);
            }
        }
        
        // Update the query parameter map with the parameters received in error response.
        StringBuilder queryStringBuilder = new StringBuilder();
        
        if (json != null) {
            if (json.has(RESPONSE_PARAM_PROPERTIES)) {
                JSONObject propertyObj = json.getJSONObject(RESPONSE_PARAM_PROPERTIES);
                if (propertyObj != null) {
                    Iterator<String> keys = propertyObj.keys();
                    while (keys.hasNext()) {
                        String key = keys.next();
                        queryParamMap.put(Encode.forUriComponent(key),
                                Encode.forUriComponent(String.valueOf(propertyObj.get(key))));
                    }
                }
            }
            
            queryParamMap.put("errorCode", Encode.forUriComponent(json.getString(RESPONSE_PARAM_CODE)));
            queryParamMap.put("errorMsg", Encode.forUriComponent(json.getString(RESPONSE_PARAM_DESCRIPTION)));
        }
        // Re-build query string
        int count = 0;
        for (Map.Entry<String, String> entry : queryParamMap.entrySet()) {
            queryStringBuilder.append(entry.getKey()).append("=").append(entry.getValue());
            count++;
            if (count < queryParamMap.size()) {
                queryStringBuilder.append("&");
            }
        }
        
        String newQueryString = queryStringBuilder.toString();
        
        redirectURL = loginDoEp;
        
        if (StringUtils.isNotBlank(newQueryString)) {
            redirectURL = redirectURL + "?" + newQueryString;
        }
        response.sendRedirect(redirectURL);
        return;
    }


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
