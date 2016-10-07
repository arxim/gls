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

            if (!Guard.checkPermission(session, Guard.PAGE_INPUT_METHOD_ALLOC_MASTER_DETAIL)) {
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
            labelMap.add("TITLE_MAIN", "Doctor Category Allocate Details", "รายการเงื่อนไขระดับกลุ่มแพทย์");
            labelMap.add("ADMISSION_TYPE_CODE", "Admission Type", "รหัส");
            labelMap.add("ORDER_ITEM_CODE", "Order item", "Order item");
            labelMap.add("DOCTOR_TREATMENT_CODE", "Doctor treatment", "แพทย์ทำการ");
            labelMap.add("DOCTOR_CATEGORY_CODE", "Doctor category", "กลุ่มแพทย์");
            labelMap.add("PRICE", "Price", "ราคา");
            labelMap.add("TAX_TYPE_CODE", "Tax type", "ประเภทภาษี");
            labelMap.add("EXCLUDE_TREATMENT", "Exclude treatment", "Exclude treatment");
            labelMap.add("EXCLUDE_TREATMENT_0", "ไม่นำไปรวมคิดขั้นบันได", "ไม่นำไปรวมคิดขั้นบันได");
            labelMap.add("EXCLUDE_TREATMENT_1", "นำไปรวมคิดขั้นบันได", "นำไปรวมคิดขั้นบันได");
            labelMap.add("GUARANTEE_AMOUNT", "Revenue for Guarantee", "จำนวนเงินคิดการันตี");
            labelMap.add("GUARANTEE_BY_DF", "DF After Allocate", "จำนวนเงินหลังแบ่ง");
            labelMap.add("GUARANTEE_BY_AMOUNT", "DF Before Allocate", "จำนวนเงินก่อนแบ่ง");
            labelMap.add("NORMAL_ALLOCATE_PCT", "Allocate Percentage", "ส่วนแบ่งอัตราส่วน");
            labelMap.add("NORMAL_ALLOCATE_AMT", "Allocate Amount", "ส่วนแบ่งเป็นเงิน");
            labelMap.add("REMARK", "Remark", "หมายเหตุ");
            labelMap.add("DOCTOR_CODE", "Doctor Code", "รหัสแพทย์");
            //labelMap.add("ACTIVE", "Status", "สถานะ");
            //labelMap.add("ACTIVE_0", "Inactive", "ไม่ใช้งาน");
            //labelMap.add("ACTIVE_1", "Active", "ใช้งาน");
            request.setAttribute("labelMap", labelMap.getHashMap());
            
            //
            // Process request
            //

            request.setCharacterEncoding("UTF-8");
            
            byte MODE = DBMgr.MODE_INSERT;
            
            DataRecord methodRec = null, doctorCategoryRec = null, orderItemRec = null , methodAllocMasterOld = null , methodAllocMasterLog = null ;

            
            if (request.getParameter("MODE") != null) {
                // Insert or update
                MODE = Byte.parseByte(request.getParameter("MODE"));

                methodRec = new DataRecord("STP_METHOD_ALLOC_MASTER");

                methodRec.addField("HOSPITAL_CODE", Types.VARCHAR, session.getAttribute("HOSPITAL_CODE").toString(), true);
                methodRec.addField("ADMISSION_TYPE_CODE", Types.VARCHAR, request.getParameter("ADMISSION_TYPE_CODE"), true);
                methodRec.addField("ORDER_ITEM_CODE", Types.VARCHAR, "");
                methodRec.addField("DOCTOR_TREATMENT_CODE", Types.VARCHAR, request.getParameter("DOCTOR_TREATMENT_CODE"));
                methodRec.addField("DOCTOR_CATEGORY_CODE", Types.VARCHAR, request.getParameter("DOCTOR_CATEGORY_CODE"), true);
                methodRec.addField("PRICE", Types.NUMERIC, "0");
                methodRec.addField("TAX_TYPE_CODE", Types.VARCHAR, request.getParameter("TAX_TYPE_CODE"));
                methodRec.addField("GUARANTEE_SOURCE",Types.VARCHAR, request.getParameter("GUARANTEE_METHOD"));
                methodRec.addField("EXCLUDE_TREATMENT", Types.VARCHAR, "N");
                methodRec.addField("NORMAL_ALLOCATE_PCT", Types.NUMERIC, request.getParameter("NORMAL_ALLOCATE_PCT"));
                methodRec.addField("NORMAL_ALLOCATE_AMT", Types.NUMERIC, request.getParameter("NORMAL_ALLOCATE_AMT"));
                methodRec.addField("REMARK", Types.VARCHAR, request.getParameter("REMARK"));
                methodRec.addField("ACTIVE", Types.VARCHAR, request.getParameter("ACTIVE"));
                methodRec.addField("UPDATE_DATE", Types.VARCHAR, JDate.getDate());
                methodRec.addField("UPDATE_TIME", Types.VARCHAR, JDate.getTime());
                methodRec.addField("USER_ID", Types.VARCHAR, session.getAttribute("USER_ID").toString());

                if (MODE == DBMgr.MODE_INSERT) {

                    if (DBMgr.insertRecord(methodRec)) {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_SUCCESS).replace("[HREF]", "input/method_alloc_master_main.jsp?DOCTOR_CATEGORY_CODE=" + methodRec.getField("DOCTOR_CATEGORY_CODE").getValue()));
                    } 
                    else {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_FAIL));
                    }
                } 
                else if (MODE == DBMgr.MODE_UPDATE) {
                	
                	/**
                	**  Set back up master method
                	**/
                	
                	methodAllocMasterOld  = DBMgr.getRecord("SELECT * FROM STP_METHOD_ALLOC_MASTER WHERE HOSPITAL_CODE = '" +  session.getAttribute("HOSPITAL_CODE").toString() + "' AND ADMISSION_TYPE_CODE = '" + request.getParameter("ADMISSION_TYPE_CODE") + "' AND DOCTOR_CATEGORY_CODE = '" + request.getParameter("DOCTOR_CATEGORY_CODE") + "' ");
                	
                	methodAllocMasterLog = new DataRecord("STP_METHOD_ALLOC_MASTER_LOG");
                	 
                	methodAllocMasterLog.addField("HOSPITAL_CODE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld, "HOSPITAL_CODE"), true);
                	methodAllocMasterLog.addField("ADMISSION_TYPE_CODE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld, "ADMISSION_TYPE_CODE"), true);
                	methodAllocMasterLog.addField("ORDER_ITEM_CODE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld, "ORDER_ITEM_CODE"));
                	methodAllocMasterLog.addField("DOCTOR_TREATMENT_CODE", Types.VARCHAR,DBMgr.getRecordValue(methodAllocMasterOld,"DOCTOR_TREATMENT_CODE"));
                	methodAllocMasterLog.addField("DOCTOR_CATEGORY_CODE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"DOCTOR_CATEGORY_CODE"), true);
                	methodAllocMasterLog.addField("PRICE", Types.NUMERIC, DBMgr.getRecordValue(methodAllocMasterOld,"PRICE"));
                	methodAllocMasterLog.addField("TAX_TYPE_CODE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"TAX_TYPE_CODE"));
                	methodAllocMasterLog.addField("GUARANTEE_SOURCE",Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"GUARANTEE_METHOD"));
                	methodAllocMasterLog.addField("EXCLUDE_TREATMENT", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"EXCLUDE_TREATMENT"));
                	methodAllocMasterLog.addField("NORMAL_ALLOCATE_PCT", Types.NUMERIC, DBMgr.getRecordValue(methodAllocMasterOld,"NORMAL_ALLOCATE_PCT"));
                	methodAllocMasterLog.addField("NORMAL_ALLOCATE_AMT", Types.NUMERIC, DBMgr.getRecordValue(methodAllocMasterOld,"NORMAL_ALLOCATE_AMT"));
                	methodAllocMasterLog.addField("REMARK", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"REMARK"));
                	methodAllocMasterLog.addField("ACTIVE", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"ACTIVE"));
                	methodAllocMasterLog.addField("UPDATE_DATE", Types.VARCHAR ,  DBMgr.getRecordValue(methodAllocMasterOld,"UPDATE_DATE"));
                	methodAllocMasterLog.addField("UPDATE_TIME", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"UPDATE_TIME"));
                	methodAllocMasterLog.addField("USER_ID", Types.VARCHAR, DBMgr.getRecordValue(methodAllocMasterOld,"USER_ID"));
                	
                	
                    if (DBMgr.updateRecord(methodRec)) {
                    	
                    	/**
                    	** Set back up data method master
                    	**/ 
                    	if(!DBMgr.isExist(methodAllocMasterLog)) { 
                    		DBMgr.insertRecord(methodAllocMasterLog);
                    	} else { 
                    		DBMgr.updateRecord(methodAllocMasterLog);
                    	}
                    	
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_SUCCESS).replace("[HREF]", "input/method_alloc_master_main.jsp?DOCTOR_CATEGORY_CODE=" + methodRec.getField("DOCTOR_CATEGORY_CODE").getValue()));
                    } else {
                        session.setAttribute("MSG", labelMap.get(LabelMap.MSG_SAVE_FAIL));
                    }
                }

                response.sendRedirect("../message.jsp");
                return;
            }
            else if (request.getParameter("ADMISSION_TYPE_CODE") != null && request.getParameter("DOCTOR_CATEGORY_CODE") != null) {
                // Edit
                MODE = DBMgr.MODE_UPDATE;
                
                methodRec = DBMgr.getRecord(String.format("SELECT * FROM STP_METHOD_ALLOC_MASTER WHERE HOSPITAL_CODE = '%1$s' AND DOCTOR_CATEGORY_CODE = '%2$s' AND ADMISSION_TYPE_CODE = '%3$s'", session.getAttribute("HOSPITAL_CODE"), request.getParameter("DOCTOR_CATEGORY_CODE"), request.getParameter("ADMISSION_TYPE_CODE")));
                
                doctorCategoryRec = DBMgr.getRecord(String.format("SELECT CODE, DESCRIPTION FROM DOCTOR_CATEGORY WHERE CODE = '%1$s'", request.getParameter("DOCTOR_CATEGORY_CODE")));

                orderItemRec = DBMgr.getRecord(String.format("SELECT CODE, DESCRIPTION_%1$s FROM ORDER_ITEM WHERE CODE = '%2$s'", labelMap.getFieldLangSuffix(), DBMgr.getRecordValue(methodRec, "ORDER_ITEM_CODE")));
            }
            else if (request.getParameter("DOCTOR_CATEGORY_CODE") != null) {
                // New
                MODE = DBMgr.MODE_INSERT;
                
                doctorCategoryRec = DBMgr.getRecord(String.format("SELECT CODE, DESCRIPTION FROM DOCTOR_CATEGORY WHERE CODE = '%1$s'", request.getParameter("DOCTOR_CATEGORY_CODE")));
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
            
            function DOCTOR_CATEGORY_CODE_KeyPress(e) {
                var key = window.event ? window.event.keyCode : e.which;    // ? IE : Firefox

                if (key == 13) {
                    document.mainForm.DOCTOR_CATEGORY_CODE.blur();
                    return false;
                }
                else {
                    return true;
                }
            }

            function AJAX_Refresh_DOCTOR_CATEGORY() {
                var target = "../../RetrieveData?TABLE=DOCTOR_CATEGORY&COND=CODE='" + document.mainForm.DOCTOR_CATEGORY_CODE.value + "' AND HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>'";
                AJAX_Request(target, AJAX_Handle_Refresh_DOCTOR_CATEGORY);
            }
            
            function AJAX_Handle_Refresh_DOCTOR_CATEGORY() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    // Data not found
                    if (!isXMLNodeExist(xmlDoc, "CODE")) {
                        document.mainForm.DOCTOR_CATEGORY_CODE.value = "";
                        document.mainForm.DOCTOR_CATEGORY_DESCRIPTION.value = "";
                        return;
                    }
                    
                    // Data found
                    document.mainForm.DOCTOR_CATEGORY_DESCRIPTION.value = getXMLNodeValue(xmlDoc, "DESCRIPTION");
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
                var target = "../../RetrieveData?TABLE=STP_METHOD_ALLOC_MASTER&COND=HOSPITAL_CODE='<%=session.getAttribute("HOSPITAL_CODE")%>' AND ADMISSION_TYPE_CODE='" + document.mainForm.ADMISSION_TYPE_CODE.value + "' AND DOCTOR_CATEGORY_CODE='" + document.mainForm.DOCTOR_CATEGORY_CODE.value + "'";
                AJAX_Request(target, AJAX_Handle_Verify_Data);
            }
            
            function AJAX_Handle_Verify_Data() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;

                    var beExist = isXMLNodeExist(xmlDoc, "DOCTOR_CATEGORY_CODE");
                    
                    switch (document.mainForm.MODE.value) {
                        case "<%=DBMgr.MODE_INSERT%>" :
                            if (beExist) {
                                if (confirm("<%=labelMap.get("CONFIRM_REPLACE_DATA")%>")) {
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
                if (!isObjectEmptyString(document.mainForm.DOCTOR_CATEGORY_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    !isObjectEmptyString(document.mainForm.ADMISSION_TYPE_CODE, '<%=labelMap.get(LabelMap.ALERT_REQUIRED_FIELD)%>') && 
                    isObjectValidNumber(document.mainForm.NORMAL_ALLOCATE_PCT, '<%=labelMap.get(LabelMap.ALERT_INVALID_NUMBER)%>') && 
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
        <form id="mainForm" name="mainForm" method="post" action="method_alloc_master_detail.jsp">
            <input type="hidden" id="MODE" name="MODE" value="<%= MODE %>" />
            <table class="form">
                <tr>
                    <th colspan="4">
                        <div style="float: left;">${labelMap.TITLE_MAIN}</div>
                    </th>
                </tr>
                <tr>
                  <td class="label">
                    <label for="DOCTOR_CATEGORY_CODE"><span class="style1">${labelMap.DOCTOR_CATEGORY_CODE}*</span></label>                    </td>
                    <td class="input" colspan="3">
                        <input name="DOCTOR_CATEGORY_CODE" type="text" class="short" id="DOCTOR_CATEGORY_CODE" maxlength="20" value="<%= DBMgr.getRecordValue(doctorCategoryRec, "CODE")%>" onkeypress="return DOCTOR_CATEGORY_CODE_KeyPress(event);" onblur="AJAX_Refresh_DOCTOR_CATEGORY();" />
                        <!-- <input type="image" class="image_button" src="../../images/search_button.png" alt="" onclick="openSearchForm('../search.jsp?TABLE=DOCTOR_CATEGORY&DISPLAY_FIELD=DESCRIPTION&BEINSIDEHOSPITAL=1&BEACTIVE=1&TARGET=DOCTOR_CATEGORY_CODE&HANDLE=AJAX_Refresh_DOCTOR_CATEGORY'); return false;" /> -->
                        <input name="DOCTOR_CATEGORY_DESCRIPTION" type="text" class="mediumMax" id="DOCTOR_CATEGORY_DESCRIPTION" readonly="readonly" value="<%= DBMgr.getRecordValue(doctorCategoryRec, "DESCRIPTION")%>" maxlength="255" />                    
                    </td>
                </tr>
                <tr>
                    <td class="label"><label for="ADMISSION_TYPE_CODE"><span class="style1">${labelMap.ADMISSION_TYPE_CODE}*</span></label></td>
                    <td colspan="3" class="input">
                        <%= DBMgr.generateDropDownList("ADMISSION_TYPE_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM ADMISSION_TYPE ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "ADMISSION_TYPE_CODE")) %>
                    </td>
                </tr>
                <tr>
                    <td class="label"><label for="DOCTOR_TREATMENT_CODE"><span class="style1">${labelMap.DOCTOR_TREATMENT_CODE}*</span></label></td>
                    <td colspan="3" class="input">
                        <%= DBMgr.generateDropDownList("DOCTOR_TREATMENT_CODE", "medium", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM DOCTOR_TREATMENT ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "DOCTOR_TREATMENT_CODE")) %>
                    </td>
                </tr>
                <tr>
                    <td class="label"><label for="aText"><span class="style1">${labelMap.TAX_TYPE_CODE}*</span></label></td>
                    <td colspan="" class="input">
                        <%=DBMgr.generateDropDownList("TAX_TYPE_CODE", "short", "inActive", "SELECT CODE, DESCRIPTION, ACTIVE FROM TAX_TYPE ORDER BY DESCRIPTION", "DESCRIPTION", "CODE", DBMgr.getRecordValue(methodRec, "TAX_TYPE_CODE"))%>
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
                <tr>
                    <td class="label"><label for="NORMAL_ALLOCATE_PCT">${labelMap.NORMAL_ALLOCATE_PCT}*</label></td>
                    <td class="input"><input type="text" id="NORMAL_ALLOCATE_PCT" name="NORMAL_ALLOCATE_PCT" class="short alignRight" value="<%= DBMgr.getRecordValue(methodRec, "NORMAL_ALLOCATE_PCT") %>" maxlength="13" /></td>
                    <td class="label"><label for="NORMAL_ALLOCATE_AMT">${labelMap.NORMAL_ALLOCATE_AMT}*</label></td>
                    <td class="input"><input type="text" id="NORMAL_ALLOCATE_AMT" name="NORMAL_ALLOCATE_AMT" class="short alignRight" value="<%= DBMgr.getRecordValue(methodRec, "NORMAL_ALLOCATE_AMT") %>" maxlength="13" /></td>
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
                        <input type="button" id="CLOSE" name="CLOSE" class="button" value="${labelMap.CLOSE}" onclick="window.location.href='method_alloc_master_main.jsp?DOCTOR_CATEGORY_CODE=<%=request.getParameter("DOCTOR_CATEGORY_CODE")%>'" />
                    </th>
                </tr>
            </table>
        </form>
    </body>
</html>
