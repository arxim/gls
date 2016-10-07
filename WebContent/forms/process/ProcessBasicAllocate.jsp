<%@page contentType="text/html" pageEncoding="UTF-8" errorPage="../error.jsp"%>
<jsp:useBean id="pc" scope="session" class="df.bean.process.ProcessDailyCalculateBean" />
<jsp:setProperty name="pc" property="*"/> 
<%@page import="java.sql.*"%>
<%@page import="df.jsp.Guard"%>
<%@page import="df.jsp.LabelMap"%>
<%@page import="df.bean.db.conn.DBConnection"%>
<%@page import="df.bean.db.table.TRN_Error"%>
<%@page import="df.bean.obj.util.JDate"%>
<%@page import="df.bean.db.table.Batch"%>
<%@page import="df.bean.obj.doctor.DoctorList"%>
<%@page import="df.bean.obj.Item.DrMethodAllocation"%>
<%@page import="df.bean.db.table.TrnDaily"%>
<%@page import="df.bean.obj.doctor.CareProvider"%>

<%@ include file="../../_global.jsp" %>
<%@page import="df.bean.obj.util.Utils "%>
<%
      // Verify permission
      if (!Guard.checkPermission(session, Guard.PAGE_PROCESS_DEMO)) {
          response.sendRedirect("../message.jsp");
          return;
      }

      // Initial LabelMap
      if (session.getAttribute("LANG_CODE") == null) { session.setAttribute("LANG_CODE", LabelMap.LANG_EN);}
      
      LabelMap labelMap = new LabelMap(session.getAttribute("LANG_CODE").toString());
      labelMap.add("TITLE_MAIN", "Calculate Transaction", "คำนวณส่วนแบ่งเบื้องต้น");
      labelMap.add("COL_0", "No.", "ลำดับ");
      labelMap.add("COL_1", "Invoice No.", "เลขที่ใบแจ้งหนี้");
      labelMap.add("COL_2", "Line No.", "ลำดับที่");
      labelMap.add("COL_3", "Doctor", "แพทย์");
      labelMap.add("COL_4", "Message", "ข้อความ");
      labelMap.add("COL_5", "Status", "สถานะ");
      request.setAttribute("labelMap", labelMap.getHashMap());
      String startDateStr = JDate.showDate(JDate.getDate());
      String endDateStr = JDate.showDate(JDate.getDate());
      String hospitalCode = session.getAttribute("HOSPITAL_CODE").toString();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
    
        <title>${labelMap.TITLE_MAIN}</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <link rel="stylesheet" type="text/css" href="../../css/share.css" media="all" />
        <link type="text/css" href="../../css/themes/custom-theme/jquery.ui.all.css" rel="stylesheet" media="screen"/>
        <script type="text/javascript" src="../../javascript/util.js"></script>
        <script type="text/javascript" src="../../javascript/ajax.js"></script>
        <script type="text/javascript" src="../../javascript/jquery-1.6.2.min.js"></script>
        <script type="text/javascript" src="../../javascript/jquery-ui-1.8.16.custom.min.js"></script>
        <script type="text/javascript" src="../../javascript/calendar.js"></script>
        <script src="../../javascript/DOMPaser.js" type="text/javascript"></script>
        <script type="text/javascript">
    
	        $(document).ready(function(){ 
				$( "#START_DATE" ).datepicker({
					changeMonth: true,
					changeYear: true,
					buttonImageOnly: true,
					dateFormat: 'dd/mm/yy'
				}); 
				$( "#END_DATE" ).datepicker({
					changeMonth: true,
					changeYear: true,
					buttonImageOnly: true,
					dateFormat: 'dd/mm/yy'
				});				
			});
        
			var xmlhttp;
			function AJAX_Send_Request(){
	            if (currentRowID < jsarray2.length ) {
					var target = "ProcessDailyCalculateCont.jsp?"
                        + "ROW="+toRowID
                        + "&currentRowID="+(currentRowID+1)
                        + "&HOSPITAL_CODE=<%=session.getAttribute("HOSPITAL_CODE").toString()%>"
                        + "&INVOICE_NO=" + jsarray2[currentRowID]
                        + "&LINE_NO=" +jsarray3[currentRowID]
                        + "&START_DATE=" + document.mainForm.START_DATE.value
                        + "&END_DATE=" + document.mainForm.END_DATE.value;
	                xmlhttp=GetXmlHttpObject();

	                if (xmlhttp==null){
						alert ("Your browser does not support Ajax HTTP");
	                 	return;
	                }
               	    xmlhttp.onreadystatechange=getOutput;
               	    xmlhttp.open("POST",target,true);
               	    xmlhttp.send(null);
	            }else{
	                document.mainForm.RUN.disabled = false;
	                document.mainForm.STOP.disabled = true;
	                document.mainForm.CLOSE.disabled = false;
	                alert("Process Complete");	               
	            }
			}
			function LTrim(str){
				if (str==null){return null;}
				for(var i=0;str.charAt(i)==" ";i++);
				return str.substring(i,str.length);
				}
			var numcount=1;
			function getOutput(){
				if (xmlhttp.readyState==4){
   					var xmlDoc = xmlhttp.responseText;
   					var output = xmlDoc.replace(/^\s*$[\n\r]{1,}/gm, '');
 					var xmlDoc = null;
		            if (window.DOMParser) {
		                var parser = new DOMParser ();
		                xmlDoc = parser.parseFromString (output, "text/xml");
		            } else if (window.ActiveXObject) {
		                xmlDoc = new ActiveXObject ("Microsoft.XMLDOM");
		                xmlDoc.async = false;
		                xmlDoc.loadXML (output);
		            }
				   						
   						
                    if (xmlDoc== null) {
                        alert("Exception in update process");
                        return;
                    }
                    
                    if (xmlDoc.getElementsByTagName("code")[0].firstChild.nodeValue == "0") {
                       	var tbl = document.getElementById('dataTable');
        				var row = tbl.insertRow(tbl.rows.length);   
        				for (var i = 0; i < tbl.rows[1].cells.length; i++) {  
        					if(i==5){
        						createCell(row.insertCell(i), '<img src="../../images/failed_icon.gif" alt="" />', 'row'); 
        					}else if(i==4){
        						createCell(row.insertCell(i), "<div title=\""+xmlDoc.getElementsByTagName('msg_detail')[0].firstChild.nodeValue+"\">"+xmlDoc.getElementsByTagName('msg_<%=session.getAttribute("LANG_CODE")%>')[0].firstChild.nodeValue+"</div>", 'row'); 
        					}else if(i==3){
        						createCell(row.insertCell(i), jsarray4[currentRowID], 'row'); 
        					}else if(i==2){
        						createCell(row.insertCell(i), jsarray3[currentRowID], 'row'); 
        					}else if(i==1){
        						createCell(row.insertCell(i), jsarray2[currentRowID], 'row'); 
        					}else if(i==0){
        						createCell(row.insertCell(i), numcount++, 'row'); 
        					}
        				}
                    }else{

                    }
    				if(!stopclick){
				  	document.getElementById("PROGRESS").innerHTML = ((currentRowID+1)) + " / " + (jsarray2.length);
					currentRowID++;
					AJAX_Send_Request();
    				}else{
    					currentRowID=(jsarray2.length-1);
    					AJAX_Send_Request();
    				} 
				}
			}
			function createCell(cell, text, style) {  
				var div = document.createElement('div'),  
				txt = document.createTextNode(text);
				div.setAttribute("align", "center");
				div.innerHTML=text;
				cell.appendChild(div);    
			}
			function GetXmlHttpObject(){
				if (window.XMLHttpRequest){
       				return new XMLHttpRequest();
				}
				if (window.ActiveXObject){
      				return new ActiveXObject("Microsoft.XMLHTTP");
				}
				return null;
			}
            var fromRowID = 0;
            var toRowID = 0;
            var numRow = 0;
            var currentRowID = 0;
            var table = document.getElementById("dataTable"); 
            function RUN_Click() {
            	toRowID=jsarray2.length;
                document.mainForm.RUN.disabled = true;
                document.mainForm.STOP.disabled = false;
                document.mainForm.CLOSE.disabled = true;
                document.getElementById("PROGRESS").innerHTML = (currentRowID+1) + " / " + (jsarray2.length-1);
                stopclick=false;
                
                AJAX_Send_Request();
            }
            var stopclick=false;
            function STOP_Click(){
            	 document.mainForm.RUN.disabled = true;
            	 document.mainForm.STOP.disabled = true;
            	  document.mainForm.CLOSE.disabled = false;
            	stopclick=true;
            }
            
     
		</script>
	</head>
    <body>
	<form id="mainForm" name="mainForm" method="post" action="ProcessDailyCalculate.jsp">
	<table class="form">
 		<tr><th colspan="4">${labelMap.TITLE_MAIN}</th></tr>
		<tr>
        	<td class="label"><label for="START_DATE">${labelMap.START_DATE}</label></td>
            <td class="input">
            	<input type="text" id="START_DATE" name="START_DATE" class="short" value="<%=request.getParameter("START_DATE") == null ? startDateStr : request.getParameter("START_DATE")%>" />
            </td>
            <td class="label"><label for="END_DATE">${labelMap.END_DATE}</label></td>
            <td class="input">
            	<input type="text" id="END_DATE" name="END_DATE" class="short" value="<%=request.getParameter("END_DATE") == null ? endDateStr : request.getParameter("END_DATE")%>" />
            </td>
		</tr>
        <tr>
        	<th colspan="4" class="buttonBar">
        	    <input type="button" id="SELECT" name="SELECT" class="button" value="${labelMap.SELECT}" onclick="window.location = 'ProcessDailyCalculate.jsp?START_DATE=' + document.mainForm.START_DATE.value + '&END_DATE=' +  document.mainForm.END_DATE.value; return false;" />
	            <input type="button" id="RUN" name="RUN" class="button" value="${labelMap.RUN}" onclick="RUN_Click()" disabled="disabled" />
	            <input type="button" id="STOP" name="STOP" class="button" value="Stop" onclick="STOP_Click()" disabled="disabled" />
	            <input type="button" id="CLOSE" name="CLOSE" class="button" value="${labelMap.CLOSE}" onclick="window.location='../process/ProcessFlow.jsp'" />
			</th>
        </tr>
	</table>
    <hr></hr>
    <table class="data" id="dataTable">
		<tr>
             <th colspan="6" class="alignLeft">
                <div style="float: left;">${labelMap.TITLE_MAIN}</div>
                <div style="float: right;" id="PROGRESS" name="PROGRESS"></div>
            </th>
        </tr>
        <tr>
            <td class="sub_head"><%=labelMap.get("COL_0")%></td>
            <td class="sub_head"><%=labelMap.get("COL_1")%></td>
            <td class="sub_head"><%=labelMap.get("COL_2")%></td>
            <td class="sub_head"><%=labelMap.get("COL_3")%></td>
            <td class="sub_head"><%=labelMap.get("COL_4")%></td>
            <td class="sub_head"><%=labelMap.get("COL_5")%></td>
        </tr>
      
     
<%
	DBConnection con = new DBConnection();
	con.connectToLocal();
	String sql = "SELECT DISTINCT INVOICE_NO, LINE_NO, DOCTOR_CODE "+
	"FROM TRN_DAILY " +
    "WHERE HOSPITAL_CODE = '" + session.getAttribute("HOSPITAL_CODE").toString() + "' " +
    "AND (TRANSACTION_DATE >= '" + JDate.saveDate(request.getParameter("START_DATE")) + "' " +     // #20071123# this.getStartComputeDate()
    "AND TRANSACTION_DATE <= '" + JDate.saveDate(request.getParameter("END_DATE")) + "') " +  // #20071123# this.getEndComputeDate()
    "AND (BATCH_NO IS NULL OR BATCH_NO = '') " +
    "AND ACTIVE = '1' " +
    "AND AMOUNT_AFT_DISCOUNT <> 0 " +
    "AND (COMPUTE_DAILY_DATE IS NULL OR COMPUTE_DAILY_DATE = '') "+
	"ORDER BY INVOICE_NO";
	ResultSet rs = con.executeQuery(sql);
	
	int i = 0;
	out.print("<script type=\"text/javascript\">var jsarray1=new Array("+rs.getRow()+");");
	out.print("var jsarray2=new Array("+rs.getRow()+");");
	out.print("var jsarray3=new Array("+rs.getRow()+");");
	out.print("var jsarray4=new Array("+rs.getRow()+");");
	while (rs.next()) {
		 out.print( "jsarray1["+i+"]='"+i+"';"); 
		 out.print( "jsarray2["+i+"]='"+rs.getString("INVOICE_NO")+"';"); 
		 out.print( "jsarray3["+i+"]='"+rs.getString("LINE_NO")+"';"); 
		 out.print( "jsarray4["+i+"]='"+rs.getString("DOCTOR_CODE")+"';\n"); 
		i++;
		}
		out.print("</script>");
        if (rs != null) {
            rs.close();
        }
        con.Close();
	
%>
	<script type="text/javascript">
		numRow = <%=i%>;
	    document.getElementById("PROGRESS").innerHTML = "0 / " +numRow;
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