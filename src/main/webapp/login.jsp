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
<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import = "java.util.ResourceBundle" %>
<%@ page import="org.apache.log4j.Logger" %>

<html lang="en">
<head>
    <meta charset="utf-8">
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
    
    <title>Login Portal</title>
</head>

<body style="font-family: 'Roboto', sans-serif;">
<div>&nbsp;</div>


<%
    Logger log = Logger.getLogger("org.sample.login.portal.login");
    String queryString = request.getQueryString();
    String errorMessage = "Authentication Failed! Please Retry";
    String loginFailed = "false";
    final String AUTH_FAILURE_PARAM = "authFailure";
    final String AUTH_FAILURE_MSG_PARAM = "authFailureMsg";
    final String SESSION_DATA_KEY_PARAM = "sessionDataKey";
    String formActionURL = "authenticate.do";
    
    
    try {
        ResourceBundle resource = ResourceBundle.getBundle("loginportal");
        formActionURL = resource.getString("authentication.do.url");
    } catch (Exception e) {
        log.error("Error while retrieving properties from loginportal.properties file.",e);
        log.info("Using default property values.");
    }
    
    
    if (request.getParameter(AUTH_FAILURE_PARAM) != null &&
            "true".equals(request.getParameter(AUTH_FAILURE_PARAM))) {
        loginFailed = "true";
        
        if (request.getParameter(AUTH_FAILURE_MSG_PARAM) != null) {
            errorMessage = request.getParameter(AUTH_FAILURE_MSG_PARAM);
            
            if (errorMessage.equalsIgnoreCase("login.fail.message")) {
                errorMessage = "Authentication Failed! Please Retry.";
            }
        }
    }
    
    if (queryString != null && queryString.length() != 0) {
        formActionURL = formActionURL + "?" + queryString;
    }
%>

<div style=" position: absolute;top: 40%; left: 50%; transform: translate(-50%, -50%);">
    <div>
        <div>
            <div>
                <h1 style="padding-bottom: 30px">Login Portal</h1>
            </div>
        </div>
    </div>
    
    <form action='<%=formActionURL%>' method="post" id="loginForm" class="form-horizontal">
        <div>
            <div>
                <!-- Username -->
                <div style="margin-bottom: 20px">
                    <label for="username">Username :</label>
                    
                    <div>
                        <input type="text" id='username' name="username" size='40'/>
                    </div>
                </div>
                <!--Password-->
                <div style="margin-bottom: 20px">
                    <label for="password">Password :</label>
                    
                    <div>
                        <input type="password" id='password' name="password" size='40'/>
                        <input type="hidden" name="sessionDataKey"
                               value='<%=request.getParameter(SESSION_DATA_KEY_PARAM)%>'/>
                    </div>
                </div>
                <div style="float: right">
                    <input type="submit" value='LOGIN'>
                </div>
            </div>
        </div>
    </form>
    <% if ("true".equals(loginFailed)) { %>
    <div style="color: red; padding-top: 40px;">
        <%=errorMessage%>
    </div>
    <% } %>
</div>

</body>
</html>
