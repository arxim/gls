package df.bean.frame;

import df.bean.process.ProcessTax406;
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Rectangle;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import java.sql.ResultSet;
import java.sql.SQLException;

import javax.swing.DefaultListModel;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;

//my import
import javax.swing.table.DefaultTableModel;
import df.bean.obj.util.DialogBox;
import df.bean.obj.util.JDate;

public class CalculatorTax406Frm1 extends CalculatorFrm1 {
    private JSeparator jSeparator4 = new JSeparator();
    private JLabel jLabel1 = new JLabel();
    private JSeparator jSeparator5 = new JSeparator();
    private String menuName;
    private JComboBox jcboYear = new JComboBox();
    private JComboBox jcboMonth = new JComboBox();
    private JLabel jLabel2 = new JLabel();

    public CalculatorTax406Frm1() { 
        try {
//            if (connect())
                jbInit();
        } catch (Exception e) {
            e.printStackTrace();
            DialogBox.ShowError("Error in CalculatorMonthlyFrm\n"+e.getMessage());
        }
    }
    
    public void finalize() {
        tblMessage = null;
    }

    private void jbInit() throws Exception {
        this.setTitle("DF Tax40(6) Calculator");
        this.setSize(new Dimension(746, 469));
        jPanelLayout.setLayout(null);
        getLstDoctorGroupCode().setBounds(new Rectangle(5, 80, 200, 330));
        statusBar.setText( "Status :" );
        this.jLabel1.setIcon(imagePhyathai);
        
        start.setIcon(imageStart);
        start.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        start_actionPerformed(e);
                    }
                });
        stop.setIcon(imageStop);
        stop.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        stop_actionPerformed(e);
                    }
                });
        close.setIcon(imageClose);
        close.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        close_actionPerformed(e);
                    }
                });

        getLstDoctorGroupCode().setSelectionMode(ListSelectionModel.SINGLE_SELECTION);        
        scrollPane = new JScrollPane(getLstDoctorGroupCode());
        scrollPane.setBounds(new Rectangle(10, 180, 80, 215));
        jPanelLayout.add(getLblDoctor(), null);
        jPanelLayout.add(getLblHospital(), null);
        // scroll pane for hospital
        scrollPaneHospitalCode = new JScrollPane(getLstHospitalCode());
        scrollPaneHospitalCode.setBounds(new Rectangle(10, 85, 80, 65));
        
        //Table Scroll Pane
        String[] columnNames={ "HOSPITAL_CODE", "DOCTOR_CODE", "DD", "MM", "YYYY",
                                "SUM_AMT", "Sum_Dr_Amt", "Sum_HP_Amt", 
                                "Sum_Tax_Dr_Amt", "Sum_Tax_Hp_Amt", 
                                "Text_Sum_Dr_Amt", "Text_Sum_Tax_Dr_Amt", "Print_Date" };
        tableModel = new DefaultTableModel(columnNames, row);
        tblMessage = new JTable(tableModel);
        scrollPaneMessage = new JScrollPane(tblMessage);
        scrollPaneMessage.setBounds(new Rectangle(95, 65, 635, 330));
        jPanelLayout.add(jLabel2, null);
        jPanelLayout.add(jcboMonth, null);
        jPanelLayout.add(jcboYear, null);
        jPanelLayout.add(jSeparator5, null);
        jPanelLayout.add(jLabel1, null);
        jPanelLayout.add(jSeparator4, null);
        jPanelLayout.add(close, null);
        jPanelLayout.add(stop, null);
        jPanelLayout.add(start, null);
        jPanelLayout.add(scrollPaneMessage, BorderLayout.CENTER);
        jPanelLayout.add(scrollPaneHospitalCode, null);
        jPanelLayout.add(scrollPane, null);
        tblMessage.setAutoscrolls(true);
        tblMessage.setAutoResizeMode(0);

        start.setBounds(new Rectangle(30, 10, 55, 35));
        start.setActionCommand("Start");
        start.setToolTipText("Start");
        stop.setBounds(new Rectangle(95, 10, 55, 35));
        stop.setActionCommand("Stop");
        stop.setToolTipText("Stop");
        close.setBounds(new Rectangle(160, 10, 55, 35));
        close.setActionCommand("Close");
        close.setToolTipText("Close");
        jSeparator4.setBounds(new Rectangle(10, 50, 720, 2));
        jLabel1.setSize(new Dimension(134, 41));
        jLabel1.setBounds(new Rectangle(590, 5, 135, 40));
        jSeparator5.setBounds(new Rectangle(10, 410, 720, 2));

        jcboYear.setBounds(new Rectangle(455, 10, 85, 30));
        jcboYear.setSelectedItem(JDate.getYear());
        jcboYear.setToolTipText("YYYY");
        jcboMonth.setBounds(new Rectangle(405, 10, 50, 30));
        jcboMonth.setSelectedItem(JDate.getMonth());
        jcboMonth.setToolTipText("MM");
        jLabel2.setText("�Ǵ��� :");
        jLabel2.setBounds(new Rectangle(360, 10, 40, 30));
        getLstHospitalCode().setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
//        addHospitalCodeToList();
        
        getLblHospital().setText("Hospital");
        getLblHospital().setBounds(new Rectangle(10, 60, 70, 25));
        getLblDoctor().setText("Doctor");
        getLblDoctor().setBounds(new Rectangle(10, 155, 70, 25));
                
        jPanelLayout.add(scrollPane, null);
        getContentPane().add(jPanelLayout, BorderLayout.CENTER);
        
        this.setHospitalCode("null");
        this.setSelected(true);
        
        jcboMonth.addItem("06");
        jcboMonth.addItem("12");
        for (int i=-1; i<2; i++) {
            jcboYear.addItem(""+(Integer.parseInt(JDate.getYear())+i));
        }
    }
    
    public DefaultListModel elementAdd(String hospitalCode) {
        DefaultListModel r = new DefaultListModel();
        String sql = "SELECT CODE FROM DOCTOR WHERE ACTIVE = '1' and PAYMENT_MODE_CODE <> 'U'";

        ResultSet rs = conn.executeQuery(sql);
        try {
            r.clear();
            while (rs.next()) {
                r.addElement(rs.getString("code"));
            }
        } catch (SQLException e) {
            // TODO
            e.printStackTrace();
        } finally {
               //Clean up resources, close the connection.
               if(rs != null) {
                  try {
                     rs.close();
                     rs = null;
                    }
                  catch (Exception ignored) { ignored.printStackTrace();   }
            }
        }
        return r;
    }
    private void close_actionPerformed(ActionEvent e) {
        this.setVisible(false);
        //dispose();
    }

    private void start_actionPerformed(ActionEvent e) {
        if (connect()) {
            addHospitalCodeToList();
            setProcess(new ProcessTax406(this.conn));
//            this.getProcess().setCalculatorFrm(this);
//            ((ProcessTax406)this.getProcess()).setMm(this.jcboMonth.getSelectedItem().toString());
//            ((ProcessTax406)this.getProcess()).setYyyy(this.jcboYear.getSelectedItem().toString());
            this.getProcess().running = true;
            this.getProcess().working = true;
            this.setRun();
//            this.getProcess().start();
        } else { 
            DialogBox.ShowError("�������ö�Դ��͡Ѻ�ҹ��������");
        }              
    }
    private void stop_actionPerformed(ActionEvent e) {
        this.stopProcess();
    }
    public void setRun() {
        start.setEnabled(false);
        stop.setEnabled(true);
    }
    public void setStop() {
        start.setEnabled(true);
        stop.setEnabled(false);        
    }
}
                    