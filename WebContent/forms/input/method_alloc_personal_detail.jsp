<%@page contentType="text/html" pageEncoding="UTF-8" errorPage="../error.jsp"%>

<%@page import="java.sql.Types"%>
<%@page import="df.jsp.Guard"%>
<%@page import="df.jsp.LabelMap"%>
<%@page import="df.jsp.Util"%>
<%@page import="df.bean.db.DBMgr"%>
<%@page import="df.bean.db.DataRecord"%>
<%@page import="df.bean.obj.util.JDate"%>

<%@ include file="../../_global.jsp" %>

<%
            //
            // Verify permission
            //

            if (!Guard.checkPermission(session, Guard.PAGE_INPUT_METHOD_ALLOC_PERSONAL_DETAIL)) {
                response.sendRedirect("../message.jsp");
                return;
            }

            //
            // Initial LabelMap
            //

            if (session.getAttribute("LANG_CODE") == null) {
                session.setAttribute("LANG_CODE", LabelMap.LANG_EN);
            }
            LabelMap labelMap = new LabelMap(session.getAttribute("LANG_CODE").toString());
            labelMap.add("TITLE_MAIN", "Special Allocate Details", "รายละเอียดเงื่อนไขการแบ่งค่าแพทย์แบบพิเศษ");
            labelMap.add("ADMISSION_TYPE_CODE", "Admission Type", "รหัส");
            labelMap.add("ORDER_ITEM_CODE", "Order Item", "Order Item");
            labelMap.add("DOCTOR_TREATMENT_CODE", "Doctor Treatment", "Doctor Treatment");
            labelMap.add("PRICE", "Price", "Price");
            labelMap.add("TAX_TYPE_CODE", "Tax Type", "Tax Type");			
			labelMap.add("EXCLUDE_TREATMENT", "Calculate Step", "คำนวณขั้นบันได");
            labelMap.add("EXCLUDE_TREATMENT_0", "No", "ไม่");
            labelMap.add("EXCLUDE_TREATMENT_1", "Yes", "ใช่");
            labelMap.add("NORMAL_ALLOCATE_PCT", "Allocate Percentage", "ส่วนแบ่งอัตราส่วน");
            labelMap.add("NORMAL_ALLOCATE_AMT", "Allocate Amount", "ราคาส่วนแบ่งแพทย์");
            labelMap.add("GUARANTEE_AMOUNT", "Revenue for Guarantee", "จำนวนเงินคิดการันตี");
            labelMap.add("GUARANTEE_BY_DF", "DF After Allocate", "จำนวนเงินหลังแบ่ง");
            labelMap.add("GUARANTEE_BY_AMOUNT", "DF Before Allocate", "จำนวนเงินก่อนแบ่ง");
            labelMap.add("REMARK", "Remark", "หมายเหตุ");
            labelMap.add("DOCTOR_CODE", "Doctor Code", "รหัสแพทย์");
            labelMap.add("TITLE_DATA", "Bank Branch", "สาขาธนาคาร");
            request.setAttribute("labelMap", labelMap.getHashMap());
            
            //
            // Process request
            //

            request.setCharacterEncoding("UTF-8");
            
            byte MODE = DBMgr.MODE_INSERT;
            DataRecord methodRec = null, doctorRec = null, orderItemRec = null , doctorRecordOld = null  , doctorRecordLog = null ;
            
            if (request.getParameter("MODE") != null) {
                // Insert or update
                MODE = Byte.parseByte(request.getParameter("MODE"));

                methodRec = new DataRecord("STP_METHOD_ALLOC_PERSONAL");

                methodRec.addField("HOSPITAL_CODE", Types.VARCHAR, session.getAttribute("HOSPITAL_CODE").toString(), true);
                methodRec.addField("ADMISSION_TYPE_CODE", Types.VARCHAR, request.getParameter("ADMISSION_TYPE_CODE"), true);
                methodRec.addField("ORDER_ITEM_CODE", Types.VARCHAR, request.getParameter("ORDER_ITEM_CODE"), true);
                methodRec.addField("DOCTOR_TREATMENT_CODE", Types.VARCHAR, request.getParameter("DOCTOR_TREATMENT_CODE"), true);
                methodRec.addField("DOCTOR_CATEGORY_CODE", Types.VARCHAR, request.getParameter("DOCTOR_CODE"), true);
                methodRec.addField("DOCTOR_CODE", Types.VARCHAR, request.getParameter("DOCTOR_CODE"));
                methodRec.addField("PRICE", Types.NUMERIC, request.getParameter("PRICE"), true);
                methodRec.addField("TAX_TYPE_CODE", Types.VARCHAR, request.getParameter("TAX_TYPE_CODE"), true);
                methodRec.addField("EXCLUDE_TREATMENT", Types.VARCHAR, "N");
                methodRec.addField("GUARANTEE_SOURCE", Types.VARCHAR, request.getParameter("GUARANTEE_METHOD"));
                methodRec.addField("NORMAL_ALLOCATE_PCT", Types.NUMERIC, request.getParameter("NORMAL_ALLOCATE_PCT"), true);
                methodRec.addField("NORMAL_ALLOCATE_AMT", Types.NUMERIC, request.getParameter("NORMAL_ALLOCATE_AMT"), true);
                methodRec.addField("REMARK", Types.VARCHAR, request.getParameter("REMARK"));
                methodRec.addField("ACTIVE", Types.VARCHAR, request.getParameter("ACTIVE"));
                methodRec.addField("UPDATE_DATE", Types.VARCHAR, JDate.getDate());
                methodRec.addField("UPDATE_TIME", Types.VARCHAR, JDate.getTime());
                methodRec.addField("USER_ID", Types.VARCHAR, session.getAttribute("USER_ID").toString());

                if (MODE == DBMgr.MODE_INSERT) {

                    if (DBMgr.insertRecord(methodRec)) {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_SUCCESS).replace("[HREF]", "input/method_alloc_personal_main.jsp?DOCTOR_CODE=" + methodRec.getField("DOCTOR_CODE").getValue()));
                    } 
                    else {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_FAIL));
                    }
                } 
                else if (MODE == DBMgr.MODE_UPDATE) {
                	
                	
                	String sqlCommand = "SELECT * FROM STP_METHOD_ALLOC_PERSONAL  WHERE HOSPITAL_CODE = '"+ session.getAttribute("HOSPITAL_CODE").toString() +"' AND ADMISSION_TYPE_CODE = '" + request.getParameter("ADMISSION_TYPE_CODE") + "' " + 
                						" AND ORDER_ITEM_CODE = '" + request.getParameter("ORDER_ITEM_CODE") + "' AND DOCTOR_TREATMENT_CODE = '" + request.getParameter("DOCTOR_TREATMENT_CODE") + "' AND DOCTOR_CATEGORY_CODE = '" +  request.getParameter("DOCTOR_CODE") + "' " + 
                						" AND PRICE  = '" + request.getParameter("PRICE") + "'  AND TAX_TYPE_CODE = '" +  request.getParameter("TAX_TYPE_CODE") + "' AND  NORMAL_ALLOCATE_PCT = '" + request.getParameter("NORMAL_ALLOCATE_PCT") + "' " + 
                						" AND NORMAL_ALLOCATE_AMT = '" +  request.getParameter("NORMAL_ALLOCATE_AMT") + "' ";
                	
                	doctorRecordOld  = DBMgr.getRecord(sqlCommand);
                	
                	doctorRecordLog = new  DataRecord("STP_METHOD_ALLOC_PERSONAL_LOG");
                	
                	doctorRecordLog.addField("HOSPITAL_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld, "HOSPITAL_CODE"), true);
                	doctorRecordLog.addField("ADMISSION_TYPE_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"ADMISSION_TYPE_CODE"), true);
                	doctorRecordLog.addField("ORDER_ITEM_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"ORDER_ITEM_CODE"), true);
                	doctorRecordLog.addField("DOCTOR_TREATMENT_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld, "DOCTOR_TREATMENT_CODE"), true);
                	doctorRecordLog.addField("DOCTOR_CATEGORY_CODE", Types.VARCHAR,DBMgr.getRecordValue(doctorRecordOld, "DOCTOR_CODE"), true);
                	doctorRecordLog.addField("DOCTOR_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"DOCTOR_CODE"));
                	doctorRecordLog.addField("PRICE", Types.NUMERIC, DBMgr.getRecordValue(doctorRecordOld,"PRICE"), true);
                	doctorRecordLog.addField("TAX_TYPE_CODE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"TAX_TYPE_CODE"), true);
                	doctorRecordLog.addField("EXCLUDE_TREATMENT", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld, "EXCLUDE_TREATMENT"));
                	doctorRecordLog.addField("GUARANTEE_SOURCE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"GUARANTEE_METHOD"));
                	doctorRecordLog.addField("NORMAL_ALLOCATE_PCT", Types.NUMERIC, DBMgr.getRecordValue(doctorRecordOld,"NORMAL_ALLOCATE_PCT"), true);
                	doctorRecordLog.addField("NORMAL_ALLOCATE_AMT", Types.NUMERIC, DBMgr.getRecordValue(doctorRecordOld,"NORMAL_ALLOCATE_AMT"), true);
                	doctorRecordLog.addField("REMARK", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"REMARK"));
                	doctorRecordLog.addField("ACTIVE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"ACTIVE"));
                	doctorRecordLog.addField("UPDATE_DATE", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"UPDATE_DATE"));
                	doctorRecordLog.addField("UPDATE_TIME", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"UPDATE_TIME"));
                	doctorRecordLog.addField("USER_ID", Types.VARCHAR, DBMgr.getRecordValue(doctorRecordOld,"USER_ID"));
                	
                    if (DBMgr.updateRecord(methodRec)) {
                    
                      	/**
                      	**	 Set back up data 
                      	**/
                      	if(!DBMgr.isExist(doctorRecordLog)) { 
                      		DBMgr.insertRecord(doctorRecordLog);
                      	} else {
                      		DBMgr.updateRecord(doctorRecordLog);
                      	}
                      	
                    	session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_SUCCESS).replace("[HREF]", "input/method_alloc_personal_main.jsp?DOCTOR_CODE=" + methodRec.getField("DOCTOR_CODE").getValue()));
                    } 
                    else {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_FAIL));
                    }
                }

                response.sendRedirect("../message.jsp");
                return;
            }
            else if (request.getParameter("ADMISSION_TYPE_CODE") != null && request.getParameter("DOCTOR_CODE") != null && request.getParameter("ORDER_ITEM_CODE") != null) {
                // Edit
                MODE = DBMgr.MODE_UPDATE;
                
                String query = String.format("SELECT * FROM STP_METHOD_ALLOC_PERSONAL WHERE HOSPITAL_CODE = '%1$s' AND ADMISSION_TYPE_CODE = '%2$s' AND ORDER_ITEM_CODE = '%3$s' AND DOCTOR_TREATMENT_CODE = '%4$s' AND DOCTOR_CODE = '%5$s' AND PRICE = %6$s AND TAX_TYPE_CODE = '%7$s' AND EXCLUDE_TREATMENT = '%8$s' AND NORMAL_ALLOCATE_PCT = %9$s AND NORMAL_ALLOCATE_AMT = %10$s", session.getAttribute("HOSPITAL_CODE"), request.getParameter("ADMISSION_TYPE_CODE"), request.getParameter("ORDER_ITEM_CODE"), request.getParameter("DOCTOR_TREATMENT_CODE"), request.getParameter("DOCTOR_CODE"), request.getParameter("PRICE"), request.getParameter("TAX_TYPE_CODE"), request.getParameter("EXCLUDE_TREATMENT"), request.getParameter("NORMAL_ALLOCATE_PCT"), request.getParameter("NORMAL_ALLOCATE_AMT"));
                methodRec = DBMgr.getRecord(query);
                
                doctorRec = DBMgr.getRecord(String.format("SELECT CODE, NAME_%1$s FROM DOCTOR WHERE CODE = '%2$s'", labelMap.getFieldLangSuffix(), request.getParameter("DOCTOR_CODE")));

                orderItemRec = DBMgr.getRecord(String.format("SELECT CODE, DESCRIPTION_%1$s FROM ORDER_ITEM WHERE CODE = '%2$s'", labelMap.getFieldLangSuffix(), request.getParameter("ORDER_ITEM_CODE")));
            }
            else if (request.getParameter("DOCTOR_CODE") != null) {
                // New
                MODE = DBMgr.MODE_INSERT;
                
                doctorRec = DBMgr.getRecord(String.format("SELECT CODE, NAME_%1$s FROM DOCTOR WHERE CODE = '%2$s'", labelMap.getFieldLangSuffix(), request.getParameter("DOCTOR_CODE")));
            }
            /*else {
                response.sendRedirect("../message.jsp");
            }*/
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>${labelMap.TITLE_MAIN}</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <link rel="stylesheet" type="text/css" href="../../css/share.css" media="all" />
        <script type="text/javascript" src="../../javascript/ajax.js"></script>
        <script type="text/javascript" src="../../javascript/search_form.js"></script>
        <script type="text/javascript" src="../../javascript/util.js"></script>
        <script type="text/javascript">
            
            function DOCTOR_CODE_KeyPress(e) {
                var key = window.event ? window.event.keyCode : e.which;    // ? IE : Firefox

                if (key == 13) {
                    document.mainForm.DOCTOR_CODE.blur();
                    return false;
                }
                else {
                    return true;
                }
            }

            function AJAX_Refresh_DOCTOR() {
                var target = "../../RetrieveData?TABLE=DOCTOR&COND=CODE='" + document.mainForm.DOCTOR_CODE.value +"' AND HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>'";
                AJAX_Request(target, AJAX_Handle_Refresh_DOCTOR);
            }
            
            function AJAX_Handle_Refresh_DOCTOR() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    if (!isXMLNodeExist(xmlDoc, "CODE")) {
                        document.mainForm.DOCTOR_NAME.value = "";
                        return;
                    }
                    
                    // Data found
                    document.mainForm.DOCTOR_NAME.value = getXMLNodeValue(xmlDoc, "NAME_" + "<%= labelMap.getFieldLangSuffix() %>");
                }
            }
            
            function ORDER_ITEM_CODE_KeyPress(e) {
                var key = window.event ? window.event.keyCode : e.which;    // ? IE : Firefox

                if (key == 13) {
                    document.mainForm.ORDER_ITEM_CODE.blur();
                    return false;
                }
                else {
                    return true;
                }
            }

            function AJAX_Refresh_ORDER_ITEM() {
                var target = "../../RetrieveData?TABLE=ORDER_ITEM&COND=CODE='" + document.mainForm.ORDER_ITEM_CODE.value + "' AND HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>'";
                AJAX_Request(target, AJAX_Handle_ORDER_ITEM);
            }
            
            function AJAX_Handle_ORDER_ITEM() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    if (!isXMLNodeExist(xmlDoc, "CODE")) {
                        // Data not found
                        document.mainForm.ORDER_ITEM_CODE.value = "";
                        document.mainForm.ORDER_ITEM_DESCRIPTION.value = "";
                    }
                    else {
                        // Data found
                        document.mainForm.ORDER_ITEM_DESCRIPTION.value = getXMLNodeValue(xmlDoc, "DESCRIPTION_<%=labelMap.getFieldLangSuffix()%>");
                    }
                }
            }

            function AJAX_VerifyData() {
                var target = "../../RetrieveData?TABLE=STP_METHOD_ALLOC_PERSONAL&COND=HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>' AND ADMISSION_TYPE_CODE='" + document.mainForm.ADMISSION_TYPE_CODE.value + "' AND ORDER_ITEM_CODE='" + document.mainForm.ORDER_ITEM_CODE.value + "' AND DOCTOR_TREATMENT_CODE='" + document.mainForm.DOCTOR_TREATMENT_CODE.value + "' AND DOCTOR_CODE='" + document.mainForm.DOCTOR_CODE.value + "' AND PRICE=" + document.mainForm.PRICE.value + " AND TAX_TYPE_CODE='" + document.mainForm.TAX_TYPE_CODE.value + "' AND NORMAL_ALLOCATE_PCT=" + document.mainForm.NORMAL_ALLOCATE_PCT.value + " AND NORMAL_ALLOCATE_AMT=" + document.mainForm.NORMAL_ALLOCATE_AMT.value + "";
                AJAX_Request(target, AJAX_Handle_Verify_Data);
            }
            
            function AJAX_Handle_Verify_Data() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    var beExist = isXMLNodeExist(xmlDoc, "DOCTOR_CODE");
                    
                    switch (document.mainForm.MODE.value) {
                        case "<%=DBMgr.MODE_INSERT%>" :
                            if (beExist) {
                                if (confirm("<%=labelMap.get(LabelMap.CONFIRM_REPLACE_DATA)%>")) {
                                    document.mainForm.MODE.value= "<%=DBMgr.MODE_UPDATE%>";
                                    document.mainForm.submit();
                                }
                            }
                            else {
                                document.mainForm.submit();
                            }
                            break;
                        case "<%=DBMgr.MODE_UPDATE%>" :
                            if (beExist) {
                                document.mainForm.submit();
                            }
                            else {
                                if (confirm("<%=labelMap.get(LabelMap.CONFIRM_ADD_NEW_DATA)%>")) {
                                    document.mainForm.MODE.value= "<%=DBMgr.MODE_INSERT%>";
                                    document.mainForm.submit();
                                }
                            }
                            break;
                    }
                }
            }

            function SAVE_Click() {
                if (!isObjectEmptyString(document.mainForm.DOCTOR_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.ADMISSION_TYPE_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.ORDER_ITEM_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.DOCTOR_TREATMENT_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.TAX_TYPE_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.PRICE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    isObjectValidNumber(document.mainForm.PRICE, '<%=labelMap.get(LabelMap.ALERT_INVALID_NUMBER)%>') && 
                    !isObjectEmptyString(document.mainForm.NORMAL_ALLOCATE_PCT, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    isObjectValidNumber(document.mainForm.NORMAL_ALLOCATE_PCT, '<%=labelMap.get(LabelMap.ALERT_INVALID_NUMBER)%>') && 
                    !isObjectEmptyString(document.mainForm.NORMAL_ALLOCATE_AMT, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    isObjectValidNumber(document.mainForm.NORMAL_ALLOCATE_AMT, '<%=labelMap.get(LabelMap.ALERT_INVALID_NUMBER)%>')) {
                    AJAX_VerifyData();
                }
            }
            
        </script>
        <style type="text/css">
<!--
.style1 {color: #003399}
-->
        </style>
</head>
    <body>
        <form id="mainForm" name="mainForm" method="post" action="method_alloc_personal_detail.jsp">
            <input type="hidden" id="MODE" name="MODE" value="<%= MODE %>" />
            <table class="form">
                <tr>
                    <th colspan="4">${labelMap.TITLE_MAIN}</th>
                </tr>
                <tr>
                    <td class="label"><label for="DOCTOR_CODE"><span class="style1">${labelMap.DOCTOR_CODE}*</span></label></td>
                    <td colspan="3" class="input">
                        <input type="text id="DOCTOR_CODE" name="DOCTOR_CODE" class="short" value="<%= DBMgr.getRecordValue(doctorRec, "CODE") %>" onkeypress="return DOCTOR_CODE_KeyPress(event);" onblur="AJAX_Refresh_DOCTOR();" />
                        <!-- <input id="SEARCH_DOCTOR_CODE" name="SEARCH_DOCTOR_CODE" type="image" class="image_button" src="../../images/search_button.png" alt="Search" onclick="openSearchForm('../search.jsp?TABLE=DOCTOR&DISPLAY_FIELD=NAME_<%= labelMap.getFieldLangSuffix() %>&TARGET=DOCTOR_CODE&BEINSIDEHOSPITAL=1&BEACTIVE=1&HANDLE=AJAX_Refresh_DOCTOR'); return false;" /> -->
                        <input type="text" id="DOCTOR_NAME" name="DOCTOR_NAME" class="long" readonly="readonly" value="<%= DBMgr.getRecordValue(doctorRec, "NAME_" + labelMap.getFieldLangSuffix()) %>" />
                    </td>
                </tr>
                <tr>
                    <td class="label"><label for="ORDER_ITEM_CODE"><span class="style1">${labelMap.ORDER_ITEM_CODE}*</span></label></td>
                    <td colspan="3" class="input">
                        <input type="text" id="ORDER_ITEM_CODE" name="ORDER_ITEM_CODE" class="short" value="<%= DBMgr.getRecordValue(orderItemRec, "CODE") %>" onkeypress="return ORDER_ITEM_CODE_KeyPress(event);" onblur="AJAX_Refresh_ORDER_ITEM();" />
                        <input id="SEARCH_ORDER_ITEM_CODE" name="SEARCH_ORDER_ITEM_CODE" type="image" class="image_button" src="../../images/search_button.png" alt="Search" onclick="openSearchForm('../search.jsp?TABLE=ORDER_ITEM&TARGET=ORDER_ITEM_CODE&BEINSIDEHOSPITAL=1&DISPLAY_FIELD=DESCRIPTION_THAI&BEACTIVE=1&HANDLE=AJAX_Refresh_ORDER_ITEM'); return false;" />
                        <input type="text" id="ORDER_ITEM_DESCRIPTION" name="ORDER_ITEM_DESCRIPTION" class="long" readonly="readonly" value="<%= DBMgr.getRecordValue(orderItemRec, "DESCRIPTION_" + labelMap.getFieldLangSuffix()) %>" />
                    </td>
                </tr>

				<tr>
                    <td class="label"><label for="ADMISSION_TYPE_CODE"><span class="style1">${labelMap.ADMISSION_TYPE_CODE}*</span></label></td>
                    <td class="input">
                        <%= DBMgr.generateDropDownList("ADMISSION_TYPE_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM ADMISSION_TYPE ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "ADMISSION_TYPE_CODE")) %>
                    </td>
					<td class="label"><label for="DOCTOR_TREATMENT_CODE"><span class="style1">${labelMap.DOCTOR_TREATMENT_CODE}*</span></label></td>
                    <td class="input">
                        <%= DBMgr.generateDropDownList("DOCTOR_TREATMENT_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM DOCTOR_TREATMENT ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "DOCTOR_TREATMENT_CODE")) %>
                    </td>
                </tr>
				<tr>
                    <td class="label"><label for="aText"><span class="style1">${labelMap.TAX_TYPE_CODE}*</span></label></td>
                    <td colspan=""class="input">
                        <%=DBMgr.generateDropDownList("TAX_TYPE_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM TAX_TYPE ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "TAX_TYPE_CODE"))%>
                    </td>
                    <td class="label"><label for="GUARANTEE_AMOUNT">${labelMap.GUARANTEE_AMOUNT}</label>                    </td>
                    <td colspan="" class="input">
					<select class="medium" id="GUARANTEE_METHOD" name="GUARANTEE_METHOD">
                        <option value="NONE"<%= DBMgr.getRecordValue(methodRec, "GUARANTEE_SOURCE").equalsIgnoreCase("NONE") ? " selected=\"selected\"" : "" %>>-- Undefine --</option>
						<option value="FULL"<%= DBMgr.getRecordValue(methodRec, "GUARANTEE_SOURCE").equalsIgnoreCase("FULL") ? " selected=\"selected\"" : "" %>>${labelMap.GUARANTEE_BY_AMOUNT}</option>
						<option value="DF"<%= DBMgr.getRecordValue(methodRec, "GUARANTEE_SOURCE").equalsIgnoreCase("DF") ? " selected=\"selected\"" : "" %>>${labelMap.GUARANTEE_BY_DF}</option>
                    </select>
					</td>
                </tr>
                <!-- 				
				<tr>
                    <td class="label"><label for="aText"><span class="style1">${labelMap.TAX_TYPE_CODE}*</span></label></td>
                    <td colspan="3"class="input">
                        <%=DBMgr.generateDropDownList("TAX_TYPE_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM TAX_TYPE ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "TAX_TYPE_CODE"))%>
                    </td>
                </tr>
				<tr>
				<td class="label"><label for="EXCLUDE_TREATMENT_1"><span class="style1">${labelMap.EXCLUDE_TREATMENT}*</span></label></td>
                    <td colspan="3" class="input">
                        <input type="radio" id="EXCLUDE_TREATMENT_1" name="EXCLUDE_TREATMENT" value="Y"<%= DBMgr.getRecordValue(methodRec, "EXCLUDE_TREATMENT").equalsIgnoreCase("Y") || DBMgr.getRecordValue(methodRec, "EXCLUDE_TREATMENT").equalsIgnoreCase("") ? " checked=\"checked\"" : ""%> />
                        <label for="EXCLUDE_TREATMENT_1">${labelMap.EXCLUDE_TREATMENT_1}</label>
                        <input type="radio" id="EXCLUDE_TREATMENT_0" name="EXCLUDE_TREATMENT" value="N"<%= DBMgr.getRecordValue(methodRec, "EXCLUDE_TREATMENT").equalsIgnoreCase("N") ? " checked=\"checked\"" : ""%> />
                        <label for="EXCLUDE_TREATMENT_0">${labelMap.EXCLUDE_TREATMENT_0}</label>
                    </td>
                </tr>
				-->
                <tr>
					<td class="label"><label for="NORMAL_ALLOCATE_PCT">${labelMap.NORMAL_ALLOCATE_PCT}*</label></td>
                    <td colspan="3" class="input"><input type="text" id="NORMAL_ALLOCATE_PCT" name="NORMAL_ALLOCATE_PCT" class="short alignRight" value="<%= DBMgr.getRecordValue(methodRec, "NORMAL_ALLOCATE_PCT") %>" maxlength="15" /></td>
                </tr>
                
                <tr>
					<td class="label"><label for="PRICE">${labelMap.PRICE}*</label></td>
                    <td class="input"><input type="text" id="PRICE" name="PRICE" class="short alignRight" value="<%= DBMgr.getRecordValue(methodRec, "PRICE") %>" maxlength="15" /></td>
                    <td class="label"><label for="NORMAL_ALLOCATE_AMT">${labelMap.NORMAL_ALLOCATE_AMT}*</label></td>
                    <td class="input"><input type="text" id="NORMAL_ALLOCATE_AMT" name="NORMAL_ALLOCATE_AMT" class="short alignRight" value="<%= DBMgr.getRecordValue(methodRec, "NORMAL_ALLOCATE_AMT") %>" maxlength="15" /></td>
                </tr>
                <tr>
                    <td class="label"><label for="REMARK">${labelMap.REMARK}</label></td>
                    <td colspan="3" class="input"><textarea id="REMARK" name="REMARK" class="long" rows="5"><%= DBMgr.getRecordValue(methodRec, "REMARK") %></textarea></td>
                </tr>
                <tr>
                    <td class="label"><label for="ACTIVE_1">${labelMap.ACTIVE}</label></td>
                    <td colspan="3" class="input">
                        <input type="radio" id="ACTIVE_1" name="ACTIVE" value="1"<%= DBMgr.getRecordValue(methodRec, "ACTIVE").equalsIgnoreCase("1") || DBMgr.getRecordValue(methodRec, "ACTIVE").equalsIgnoreCase("") ? " checked=\"checked\"" : ""%> />
                        <label for="ACTIVE_1">${labelMap.ACTIVE_1}</label>
                        <input type="radio" id="ACTIVE_0" name="ACTIVE" value="0"<%= DBMgr.getRecordValue(methodRec, "ACTIVE").equalsIgnoreCase("0") ? " checked=\"checked\"" : ""%> />
                        <label for="ACTIVE_0">${labelMap.ACTIVE_0}</label>
                    </td>
                </tr>
                <tr>
                    <th colspan="4" class="buttonBar">                        
                        <input type="button" id="SAVE" name="SAVE" class="button" value="${labelMap.SAVE}" onclick="SAVE_Click()" />
                        <input type="reset" id="RESET" name="RESET" class="button" value="${labelMap.RESET}" />
                        <input type="button" id="CLOSE" name="CLOSE" class="button" value="${labelMap.CLOSE}" onclick="window.location.href='method_alloc_personal_main.jsp?DOCTOR_CODE=<%=request.getParameter("DOCTOR_CODE")%>'" />
                    </th>
                </tr>
            </table>
        </form>
    </body>
</html>
