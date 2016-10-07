<%-- 
    Document   : ProcessImportBill
    Created on : 30 ต.ค. 2551, 13:04:52
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" errorPage="../error.jsp"%>

<%@page import="java.sql.*"%>

<%@page import="df.jsp.Guard"%>
<%@page import="df.jsp.LabelMap"%>
<%@page import="df.bean.obj.util.Utils"%>
<%@page import="df.bean.db.conn.DBConnection"%>
<%@page import="df.bean.db.table.TRN_Error"%>
<%@page import="df.bean.obj.util.JDate"%>
<%@page import="df.bean.db.table.Batch"%>
<%@page import="df.bean.process.ProcessUtil"%>
<%@include file="../../_global.jsp" %>
<%
            //
            // Verify permission
            //

            if (!Guard.checkPermission(session, Guard.PAGE_PROCESS_PREPARE_GUARANTEE)) {
                response.sendRedirect("../message.jsp");
                return;
            }

            //
            // Initial LabelMap
            //

            if (session.getAttribute("LANG_CODE") == null) {
                session.setAttribute("LANG_CODE", LabelMap.LANG_EN);
            }           
            ProcessUtil proUtil = new ProcessUtil();
            DBConnection c = new DBConnection();
            c.connectToLocal();
            Batch b = new Batch(session.getAttribute("HOSPITAL_CODE").toString(), c);
            c.Close();
            LabelMap labelMap = new LabelMap(session.getAttribute("LANG_CODE").toString());
            labelMap.add("TITLE_MAIN", "Write Off Process", "คำนวณตัดยอดหนี้สูญ");
            labelMap.add("START_DATE", "Start Date", "วันที่เริ่มต้น");
            labelMap.add("END_DATE", "End Date", "วันที่สิ้นสุด");
            labelMap.add("MM", "Month", "เดือน");
            labelMap.add("YYYY", "Year", "ปี");
            labelMap.add("COL_0", "No.", "ลำดับ");
            labelMap.add("COL_1", "Process", "ขบวนการ");
            labelMap.add("COL_2", "Month", "เดือน");
            labelMap.add("COL_3", "Status", "สถานะ");
            request.setAttribute("labelMap", labelMap.getHashMap());
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>${labelMap.TITLE_MAIN}</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <link rel="stylesheet" type="text/css" href="../../css/share.css" media="all" />
        <script type="text/javascript" src="../../javascript/util.js"></script>
        <script type="text/javascript" src="../../javascript/ajax.js"></script>
        <link rel="stylesheet" type="text/css" href="../../css/calendar.css" />
        <script type="text/javascript" src="../../javascript/calendar.js"></script>
        <script type="text/javascript">
        <%-- [ AJAX --%>
            function AJAX_Send_Request() {
		var start_date = document.mainForm.YYYY.value+document.mainForm.MM.value+'00';
		var end_date = document.mainForm.YYYY.value+document.mainForm.MM.value+'31';
                
                if (currentRowID <= toRowID ) {
                    table.rows[currentRowID].cells[2].innerHTML = '<img src="../../images/processing_icon.gif" alt="" />';
                    var target = "writeoff.jsp?"
                            + "&HOSPITAL_CODE="+"<%=session.getAttribute("HOSPITAL_CODE").toString()%>"
                            + "&START_DATE=" + start_date
                            + "&END_DATE=" + end_date;
                    AJAX_Request(target, AJAX_Handle_Response);
                }else {
//                    document.mainForm.SELECT.disabled = false;
                    document.mainForm.RUN.disabled = false;
                    document.mainForm.STOP.disabled = true;
                    document.mainForm.CLOSE.disabled = false;
                }

            }
            
            function AJAX_Handle_Response() {
                if (AJAX_IsComplete()) {
                    var xmlDoc = AJAX.responseXML;
                    if (xmlDoc.getElementsByTagName("SUCCESS")[0] == null) {
                        //alert("Exception in update process");
                        return;
                    }
                    
                    if (xmlDoc.getElementsByTagName("SUCCESS")[0].firstChild.nodeValue == "false") {
                        table.rows[currentRowID].cells[2].innerHTML = '<img src="../../images/failed_icon.gif" alt="" />';
                        alert("Process WriteOff Incomplete");
                    }else {
                        table.rows[currentRowID].cells[2].innerHTML = '<img src="../../images/succeed_icon.gif" alt="" />';
                        alert("Process WriteOff Complete");
                    }

                    document.getElementById("PROGRESS").innerHTML = (currentRowID - 1) + " / " + numRow;
                            
                    currentRowID++;
                    AJAX_Send_Request();
                }
            }
        <%-- AJAX ] --%>
            
            function SELECT_Click() {
                document.mainForm.submit();
            }
            
            var fromRowID = 0;
            var toRowID = 0;
            var numRow = 0;
            var currentRowID = 0;
            var table = document.getElementById("dataTable"); 
            
			//RUN_Click
            function RUN_Click() {
                //table high = 4 : first table(top index) = 0
                table = document.getElementById("dataTable"); 
                fromRowID = currentRowID = 2;
                toRowID = document.getElementById("dataTable").rows.length - 1;
		//alert(table+":"+document.getElementById("dataTable").rows.length);
                //document.mainForm.SELECT.disabled = true;
                document.mainForm.RUN.disabled = true;
                document.mainForm.STOP.disabled = false;
                document.mainForm.CLOSE.disabled = true;
                document.getElementById("PROGRESS").innerHTML = (currentRowID - 1) + " / " + numRow;
                AJAX_Send_Request();
            }
            
            function STOP_Click() {
                toRowID = 0;
                document.getElementById("PROGRESS").innerHTML = "";
//                document.mainForm.SELECT.disabled = false;
                document.mainForm.RUN.disabled = false;
                document.mainForm.STOP.disabled = true;
                document.mainForm.CLOSE.disabled = false;
                // Send Roll back message via AJAX here 
            }
        </script>
    </head>
    <body>
        <form id="mainForm" name="mainForm" method="post" action="ProcessWriteOff.jsp">
        	<center>
                <table width="800" border="0">
                    <tr><td align="left">
                    <b><font color='#003399'><%=Utils.getInfoPage("ProcessWriteOff.jsp", labelMap.getFieldLangSuffix(), new DBConnection(""+session.getAttribute("HOSPITAL_CODE")))%></font></b>
                    </td></tr>
				</table>
            </center>
            <table class="form">
                <tr>
                    <th colspan="4">
				  	<div style="float: left;">${labelMap.TITLE_MAIN}</div>
				 	</th>
                </tr>
                <tr>
                    <td class="label">
                        <label>${labelMap.MM}</label>
                    </td>
                    <td class="input"><%=proUtil.selectMM(session.getAttribute("LANG_CODE").toString(), "MM", b.getMm())%></td>
                    <td class="label">
                         <label>${labelMap.YYYY}</label>
					</td>
                    <td class="input"><%=proUtil.selectYY("YYYY", b.getYyyy())%></td>
                </tr>                
                <tr>
                    <th colspan="4" class="buttonBar">                        
                        <input type="button" id="RUN" name="RUN" class="button" value="${labelMap.RUN}" onclick="RUN_Click();" disabled="disabled" />
                        <input type="button" id="STOP" name="STOP" class="button" value="Stop" onclick="STOP_Click()" disabled="disabled" />
                        <input type="button" id="CLOSE" name="CLOSE" class="button" value="${labelMap.CLOSE}" onclick="window.location='../process/ProcessFlow.jsp'" />					</th>
                </tr>
            </table>
            <hr />
            <table class="data" id="dataTable" name="dataTable">
                <tr>
                    <th colspan="3" class="alignLeft">
                        <div style="float: left;">${labelMap.TITLE_MAIN}</div>
                        <div style="float: right;" id="PROGRESS" name="PROGRESS"></div>                    </th>
                </tr>
                <tr>
                    <td class="sub_head"><%=labelMap.get("COL_0")%></td>
                    <td class="sub_head"><%=labelMap.get("COL_1")%></td>
<%--                    <td class="sub_head"><%=labelMap.get("COL_2")%></td>    --%>
                    <td class="sub_head"><%=labelMap.get("COL_3")%></td>
                </tr>
                
<%
            int i = 1; //SHOW IN TITLE TABLE SUCH AS 0/3
%>
                <tr>
                    <td class="row<%=i % 2%> alignCenter"><%="1"%></td>
                    <td class="row<%=i % 2%> alignCenter"><%="Write Off Process"%></td>
                    <td class="row<%=i % 2%> alignCenter"><img src="../../images/waiting_icon.gif" alt="" /></td>
                </tr>
<%
                i ++;
%>
<script type="text/javascript">
                    numRow = <%=i - 1%>;
                    document.getElementById("PROGRESS").innerHTML = "0 / " + numRow;
</script>
            </table>
<%
            if (i > 1) {
                out.print("<script type=\"text/javascript\">document.mainForm.RUN.disabled = false;</script>");
            }

%>
        </form>
    </body>
</html>
