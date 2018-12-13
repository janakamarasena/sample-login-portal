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
<%--<%@ page import="org.apache.commons.collections.MapUtils" %>--%>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="org.apache.http.client.methods.CloseableHttpResponse" %>
<%@ page import="org.apache.http.client.methods.HttpPost" %>
<%@ page import="org.apache.http.impl.client.CloseableHttpClient" %>
<%@ page import="org.apache.http.impl.client.HttpClients" %>

<%@ page import="java.util.HashMap" %>
<%@ page
        import="java.util.Map" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="org.apache.http.HttpHeaders" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.io.IOException" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="jdk.nashorn.internal.parser.JSONParser" %>
<%@ page import="org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import = "java.util.ResourceBundle" %>

<%
    Logger log = Logger.getLogger("org.sample.login.portal.login");
    CloseableHttpClient  httpClient = HttpClients.createDefault();
    String sessionDataKey = request.getParameter("sessionDataKey");
    System.out.println("sessionDataKey: "+sessionDataKey);
    String token = "";
    String authAPIURL = "https://localhost:9443/api/identity/auth/v1.0/authenticate";
    String commonauthURL = "https://localhost:9443/commonauth";
    final String RESPONSE_PARAM_TOKEN = "token";
    
    int statusCode;
    String statusMsg ="";
    JSONObject json;
    
    try {
        ResourceBundle resource = ResourceBundle.getBundle("loginportal");
        authAPIURL = resource.getString("auth.api.url");
        commonauthURL = resource.getString("common.auth.url");
    } catch (Exception e) {
        log.error("Error while retrieving properties from loginportal.properties",e);
        log.info("Using default property values");
    }
    
    
    HttpPost httpPostRequest = new HttpPost(authAPIURL);
    String auth = request.getParameter("username") + ":" + request.getParameter("password");
    System.out.println(auth);
    byte[] encodedAuth = Base64.encodeBase64(auth.getBytes(StandardCharsets.UTF_8));
    httpPostRequest.setHeader(HttpHeaders.AUTHORIZATION,  "Basic " + new String(encodedAuth) );
    httpPostRequest.setHeader(HttpHeaders.CONTENT_TYPE, "application/json");
    
    try (CloseableHttpResponse res = httpClient.execute(httpPostRequest)) {
        
        statusCode = res.getStatusLine().getStatusCode();
        if (statusCode==200){
            json = new JSONObject(EntityUtils.toString(res.getEntity()));
            token = json.getString(RESPONSE_PARAM_TOKEN);
        }
//        String responseString = extractResponse(response);
//
//
//        JSONObject responseObj = new JSONObject(responseString);
//        if (responseObj.has(RESPONSE_PARAM_TOKEN)) {
//            authenticationResponse = populateAuthenticationSuccessResponse(responseObj);
//        } else {
//            authenticationResponse = populateAuthenticationErrorResponse(responseObj);
//        }
//        authenticationResponse.setStatusCode(statusCode);
    
    } catch (Exception e) {
        log.error("Error while calling auth rest api.",e);
    }
    
   
    
       /* AuthAPIServiceClient authAPIServiceClient = new AuthAPIServiceClient(authAPIURL);
        AuthenticationResponse authenticationResponse = authAPIServiceClient.authenticate(request.getParameter("username"),
                request.getParameter("password"));
        if (authenticationResponse instanceof AuthenticationSuccessResponse) {

            AuthenticationSuccessResponse successResponse = (AuthenticationSuccessResponse) authenticationResponse;
            token = successResponse.getToken();
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

            AuthenticationErrorResponse errorResponse = (AuthenticationErrorResponse) authenticationResponse;
            // Update the query parameter map with the parameters received in error response.
            StringBuilder queryStringBuilder = new StringBuilder();
            if (MapUtils.isNotEmpty(errorResponse.getProperties())) {
                Map<String, String> propertyMap = errorResponse.getProperties();
                for (Map.Entry<String, String> entry : propertyMap.entrySet()) {
                    queryParamMap.put(Encode.forUriComponent(entry.getKey()), Encode.forUriComponent(entry.getValue()));
                }
            }

            queryParamMap.put("errorCode", Encode.forUriComponent(errorResponse.getCode()));
            queryParamMap.put("errorMsg", Encode.forUriComponent(errorResponse.getMessage()));

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

            String redirectURL = "login.do";
            if(IdentityCoreConstants.ADMIN_FORCED_USER_PASSWORD_RESET_VIA_OTP_ERROR_CODE.equals(errorResponse.getCode())){
                String identityMgtEndpointContext =
                        application.getInitParameter("IdentityManagementEndpointContextURL");
                if (StringUtils.isBlank(identityMgtEndpointContext)) {
                    identityMgtEndpointContext = IdentityUtil.getServerURL("/accountrecoveryendpoint", true, true);
                }
                redirectURL = identityMgtEndpointContext + "/confirmrecovery.do";
            }

            if (StringUtils.isNotBlank(newQueryString)) {
                redirectURL = redirectURL + "?" + newQueryString;
            }
            response.sendRedirect(redirectURL);
            return;
        }*/

%>


<html>
<body>
<p>You are now redirected to <%=commonauthURL%> If the redirection fails, please click the post button.</p>

<form method='post' action='<%=commonauthURL%>'>
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
<%--Status: <%=statusCode%>--%>
<%--Token: <%=token%>--%>
</body>
</html>
