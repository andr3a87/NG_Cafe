package xclipsjni;

import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.File;
import java.io.IOException;
import java.util.Observable;
import java.util.Observer;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.ComboBoxModel;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JComponent;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.KeyStroke;
import javax.swing.filechooser.FileFilter;
import monitor1213.DebugFrame;


/**
 *
 * @author Matteo Madeddu, Davide Dell'Anna, Enrico Mensa
 */
public class ControlPanel extends javax.swing.JFrame implements Observer {

    
    ClipsModel model;
    PropertyMonitor agendaMonitor;
    PropertyMonitor factsMonitor;
    PropertyMonitor debugMonitor;
        
    /**
     * Creates new form ControlPanel
     */
    public ControlPanel() {
        initComponents();
    }

    public ControlPanel(ClipsModel model) {
        initComponents();
        this.model = model;
        Dimension screenDim = Toolkit.getDefaultToolkit().getScreenSize();
        Dimension propertyMonitorDim = new Dimension(624, 325);

        agendaMonitor = new PropertyMonitor("Agenda");
        agendaMonitor.setSize(propertyMonitorDim);          
        agendaMonitor.setLocation(screenDim.width - agendaMonitor.getWidth(), 0);
        
        factsMonitor = new PropertyMonitor("Facs");
        factsMonitor.setSize(propertyMonitorDim);
        factsMonitor.setLocation(screenDim.width - factsMonitor.getWidth(), agendaMonitor.getHeight());
        factsMonitor.setAutoScroll();
        
        this.model.addObserver((Observer) this);
        agendaMonitor.addWindowListener(new WindowListener() {
            @Override
            public void windowClosing(WindowEvent e) {
                visualizeAgendaButton.setSelected(false);
            }

            @Override
            public void windowOpened(WindowEvent e) {
                visualizeAgendaButton.setSelected(true);
            }

            @Override
            public void windowClosed(WindowEvent e) {
            }

            @Override
            public void windowIconified(WindowEvent e) {
            }

            @Override
            public void windowDeiconified(WindowEvent e) {
            }

            @Override
            public void windowActivated(WindowEvent e) {
            }

            @Override
            public void windowDeactivated(WindowEvent e) {
            }
        });

        factsMonitor.addWindowListener(new WindowListener() {
            @Override
            public void windowClosing(WindowEvent e) {
                visualizeFactsButton.setSelected(false);
            }

            @Override
            public void windowOpened(WindowEvent e) {
                visualizeFactsButton.setSelected(true);
            }

            @Override
            public void windowClosed(WindowEvent e) {
            }

            @Override
            public void windowIconified(WindowEvent e) {
            }

            @Override
            public void windowDeiconified(WindowEvent e) {
            }

            @Override
            public void windowActivated(WindowEvent e) {
            }

            @Override
            public void windowDeactivated(WindowEvent e) {
            }
        });
        
        this.setShortcut();
        
    }
    
    private void setShortcut() {
                /*SETTO LE SHORTCUT PER I PULSANTI DI RUN, RUN1, STEP, START E RESET
        runButton.setMnemonic(KeyEvent.VK_R); //Alt+R
        runOneButton.setMnemonic(KeyEvent.VK_T); //Alt+T
        stepButton.setMnemonic(KeyEvent.VK_S); //Alt+S
        loadDefaultFileButton.setMnemonic(KeyEvent.VK_A); //Alt+A
        resetButton.setMnemonic(KeyEvent.VK_X); //Alt+X*/
        
        
        runButton.getInputMap(runButton.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_R, InputEvent.ALT_MASK), "run");
        runOneButton.getInputMap(runOneButton.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_T, InputEvent.ALT_MASK), "run1");
        stepButton.getInputMap(stepButton.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_S, InputEvent.ALT_MASK), "step");
        loadDefaultFileButton.getInputMap(loadDefaultFileButton.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_A, InputEvent.ALT_MASK), "start");
        resetButton.getInputMap(resetButton.WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_X, InputEvent.ALT_MASK), "reset");
        
        runButton.getActionMap().put("run", new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
              runButton.doClick();
            }
        });
        runOneButton.getActionMap().put("run1", new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
              runOneButton.doClick();
            }
        });
        stepButton.getActionMap().put("step", new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
              stepButton.doClick();
            }
        });
        loadDefaultFileButton.getActionMap().put("start", new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
              loadDefaultFileButton.doClick();
            }
        });
        resetButton.getActionMap().put("reset", new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
              resetButton.doClick();
            }
        });
    }
    
    
    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        controlPanel = new javax.swing.JPanel();
        strategyLabel = new javax.swing.JLabel();
        envLabel = new javax.swing.JLabel();
        envsSelector = new javax.swing.JComboBox();
        CLPSelector = new javax.swing.JComboBox();
        loadDefaultFileButton = new javax.swing.JButton();
        runOneButton = new javax.swing.JButton();
        runButton = new javax.swing.JButton();
        visualizeAgendaButton = new javax.swing.JCheckBox();
        visualizeFactsButton = new javax.swing.JCheckBox();
        visualizeDebugButton = new javax.swing.JCheckBox();
        stepButton = new javax.swing.JButton();
        resetButton = new javax.swing.JButton();
        stepTextField = new javax.swing.JTextField();
        timeTextField = new javax.swing.JTextField();
        timeLeftTextField = new javax.swing.JTextField();
        strategyLabel1 = new javax.swing.JLabel();
        envLabel1 = new javax.swing.JLabel();
        envLabel2 = new javax.swing.JLabel();
        jSeparator1 = new javax.swing.JSeparator();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setPreferredSize(new java.awt.Dimension(800, 148));

        strategyLabel.setText("Select Strategy:");

        envLabel.setText("Select Environment:");

        envsSelector.setModel(loadEnvsFolderNames());
        envsSelector.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                envsSelectorActionPerformed(evt);
            }
        });

        CLPSelector.setModel(loadCLPFolderNames());
        CLPSelector.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                CLPSelectorItemStateChanged(evt);
            }
        });
        CLPSelector.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CLPSelectorActionPerformed(evt);
            }
        });

        loadDefaultFileButton.setFont(new java.awt.Font("Lucida Grande", 1, 14)); // NOI18N
        loadDefaultFileButton.setForeground(new java.awt.Color(0, 204, 0));
        loadDefaultFileButton.setText("Start");
        loadDefaultFileButton.setToolTipText("Alt+A");
        loadDefaultFileButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                loadDefaultFileButtonActionPerformed(evt);
            }
        });

        runOneButton.setText("Run(1)");
        runOneButton.setToolTipText("Alt+T");
        runOneButton.setEnabled(false);
        runOneButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                runOneButtonActionPerformed(evt);
            }
        });
        runOneButton.addKeyListener(new java.awt.event.KeyAdapter() {
            public void keyReleased(java.awt.event.KeyEvent evt) {
                runOneButtonKeyReleased(evt);
            }
        });

        runButton.setText("Run");
        runButton.setToolTipText("Alt+R");
        runButton.setEnabled(false);
        runButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                runButtonActionPerformed(evt);
            }
        });

        visualizeAgendaButton.setText("Agend");
        visualizeAgendaButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                visualizeAgendaButtonActionPerformed(evt);
            }
        });

        visualizeFactsButton.setText("Facts");
        visualizeFactsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                visualizeFactsButtonActionPerformed(evt);
            }
        });

        visualizeDebugButton.setText("Debug");
        visualizeDebugButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                visualizeDebugButtonActionPerformed(evt);
            }
        });

        stepButton.setText("Step");
        stepButton.setToolTipText("Alt+S");
        stepButton.setEnabled(false);
        stepButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                stepButtonActionPerformed(evt);
            }
        });

        resetButton.setFont(new java.awt.Font("Lucida Grande", 1, 12)); // NOI18N
        resetButton.setForeground(new java.awt.Color(255, 0, 0));
        resetButton.setText("Reset");
        resetButton.setToolTipText("Alt+X");
        resetButton.setEnabled(false);
        resetButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                resetButtonActionPerformed(evt);
            }
        });

        stepTextField.setEditable(false);
        stepTextField.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
        stepTextField.setText("0");
        stepTextField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                stepTextFieldActionPerformed(evt);
            }
        });

        timeTextField.setEditable(false);
        timeTextField.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
        timeTextField.setText("0");
        timeTextField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                timeTextFieldActionPerformed(evt);
            }
        });

        timeLeftTextField.setEditable(false);
        timeLeftTextField.setHorizontalAlignment(javax.swing.JTextField.RIGHT);
        timeLeftTextField.setText("0");
        timeLeftTextField.setName(""); // NOI18N
        timeLeftTextField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                timeLeftTextFieldActionPerformed(evt);
            }
        });

        strategyLabel1.setText("Left:");

        envLabel1.setText("Time:");

        envLabel2.setText("Step:");

        javax.swing.GroupLayout controlPanelLayout = new javax.swing.GroupLayout(controlPanel);
        controlPanel.setLayout(controlPanelLayout);
        controlPanelLayout.setHorizontalGroup(
            controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(controlPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jSeparator1)
                    .addGroup(controlPanelLayout.createSequentialGroup()
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(controlPanelLayout.createSequentialGroup()
                                .addComponent(visualizeAgendaButton)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(visualizeFactsButton)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(visualizeDebugButton))
                            .addGroup(controlPanelLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                                    .addGroup(controlPanelLayout.createSequentialGroup()
                                        .addComponent(strategyLabel)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(CLPSelector, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE))
                                    .addGroup(controlPanelLayout.createSequentialGroup()
                                        .addComponent(envLabel)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                        .addComponent(envsSelector, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)))))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 106, Short.MAX_VALUE)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(envLabel1)
                            .addComponent(strategyLabel1)
                            .addComponent(envLabel2))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(timeTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 89, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(stepTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 89, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(timeLeftTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 89, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(stepButton, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(runButton, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(runOneButton, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(loadDefaultFileButton, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(resetButton, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 84, javax.swing.GroupLayout.PREFERRED_SIZE))))
                .addContainerGap())
        );
        controlPanelLayout.setVerticalGroup(
            controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(controlPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(controlPanelLayout.createSequentialGroup()
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                            .addGroup(controlPanelLayout.createSequentialGroup()
                                .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                    .addComponent(runButton)
                                    .addComponent(timeLeftTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(strategyLabel1))
                                .addGap(42, 42, 42))
                            .addGroup(javax.swing.GroupLayout.Alignment.LEADING, controlPanelLayout.createSequentialGroup()
                                .addGap(6, 6, 6)
                                .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(controlPanelLayout.createSequentialGroup()
                                        .addGap(36, 36, 36)
                                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                            .addComponent(runOneButton)
                                            .addComponent(timeTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(envLabel1)))
                                    .addComponent(loadDefaultFileButton, javax.swing.GroupLayout.PREFERRED_SIZE, 64, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(stepTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(envLabel2))
                            .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(resetButton)
                                .addComponent(stepButton))))
                    .addGroup(controlPanelLayout.createSequentialGroup()
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(strategyLabel)
                            .addComponent(CLPSelector, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(envLabel)
                            .addComponent(envsSelector, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(11, 11, 11)
                        .addGroup(controlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(visualizeAgendaButton)
                            .addComponent(visualizeFactsButton)
                            .addComponent(visualizeDebugButton))
                        .addGap(1, 1, 1)))
                .addGap(8, 8, 8)
                .addComponent(jSeparator1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        timeLeftTextField.getAccessibleContext().setAccessibleDescription("");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(controlPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(controlPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void timeLeftTextFieldActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_timeLeftTextFieldActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_timeLeftTextFieldActionPerformed

    private void timeTextFieldActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_timeTextFieldActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_timeTextFieldActionPerformed

    private void stepTextFieldActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stepTextFieldActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_stepTextFieldActionPerformed

    private void resetButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetButtonActionPerformed
        this.agendaMonitor.dispose();
        this.factsMonitor.dispose();
        model.clear();
        model.resetCore();
        loadDefaultFileButton.setEnabled(true);
        runButton.setEnabled(false);
        runOneButton.setEnabled(false);
        stepButton.setEnabled(false);
        resetButton.setEnabled(false);
        this.setShortcut();
        visualizeAgendaButton.setEnabled(false);
        visualizeFactsButton.setEnabled(false);
            
    }//GEN-LAST:event_resetButtonActionPerformed

    private void stepButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_stepButtonActionPerformed
        model.setMode("STEP");
        model.resume();
        //model.step();
    }//GEN-LAST:event_stepButtonActionPerformed

    private void visualizeDebugButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_visualizeDebugButtonActionPerformed
        DebugFrame.setDebugFrameVisible(visualizeDebugButton.isSelected());
    }//GEN-LAST:event_visualizeDebugButtonActionPerformed

    private void visualizeFactsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_visualizeFactsButtonActionPerformed
        factsMonitor.setVisible(visualizeFactsButton.isSelected());
        if(visualizeFactsButton.isSelected())
            try {
                factsMonitor.setText(model.getFactList());
        } catch (ClipsException | NullPointerException ex) {
            System.out.println("The clips core is still not initialized - unable to get the facts list");
        }
    }//GEN-LAST:event_visualizeFactsButtonActionPerformed

    private void visualizeAgendaButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_visualizeAgendaButtonActionPerformed
        agendaMonitor.setVisible(visualizeAgendaButton.isSelected());
        if(visualizeAgendaButton.isSelected()) 
            try {
                agendaMonitor.setText(model.getAgenda());
        } catch (ClipsException | NullPointerException ex) {
            System.out.println("The clips core is still not initialized - unable to check the agend content");
        }
    }//GEN-LAST:event_visualizeAgendaButtonActionPerformed

    private void runButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_runButtonActionPerformed
        // Il tasto può essere Run oppure Stop (a seconda di cosa era attivo)
        if (runButton.getText().equals("Run")) {
            model.setMode("RUN");
            model.resume();
            runButton.setText("Stop");
            stepButton.setEnabled(false);
            runOneButton.setEnabled(false);
            resetButton.setEnabled(false);
        } else {
            model.setMode("STEP");
            runButton.setText("Run");
            stepButton.setEnabled(true);
            runOneButton.setEnabled(true);
            resetButton.setEnabled(true);
        }
    }//GEN-LAST:event_runButtonActionPerformed

    private void runOneButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_runOneButtonActionPerformed
            model.setMode("RUNONE");
            model.resume();
    }//GEN-LAST:event_runOneButtonActionPerformed

    private void loadDefaultFileButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_loadDefaultFileButtonActionPerformed
        loadDefaultFileButton.setEnabled(false);
        runButton.setEnabled(true);
        runOneButton.setEnabled(true);
        stepButton.setEnabled(true);
        resetButton.setEnabled(true);
        visualizeAgendaButton.setEnabled(true);
        visualizeFactsButton.setEnabled(true);
        CLPSelector.setEnabled(false);
        envsSelector.setEnabled(false);
        String strategyFolder_name = CLPSelector.getSelectedItem().toString(); //La strategia scelta
        String envsFolder_name = envsSelector.getSelectedItem().toString(); //La cartella di env scelta
        model.startCore(strategyFolder_name, envsFolder_name); //Diciamo al modello di partire
        model.setMode("START");
        model.execute();
    }//GEN-LAST:event_loadDefaultFileButtonActionPerformed

    private void CLPSelectorActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CLPSelectorActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_CLPSelectorActionPerformed

    private void envsSelectorActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_envsSelectorActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_envsSelectorActionPerformed

    private void CLPSelectorItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_CLPSelectorItemStateChanged
        // TODO add your handling code here:
    }//GEN-LAST:event_CLPSelectorItemStateChanged

    private void runOneButtonKeyReleased(java.awt.event.KeyEvent evt) {//GEN-FIRST:event_runOneButtonKeyReleased

    }//GEN-LAST:event_runOneButtonKeyReleased

    
    
    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(ControlPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(ControlPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(ControlPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(ControlPanel.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new ControlPanel().setVisible(true);
            }
        });
    }

    
    
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JComboBox CLPSelector;
    private javax.swing.JPanel controlPanel;
    private javax.swing.JLabel envLabel;
    private javax.swing.JLabel envLabel1;
    private javax.swing.JLabel envLabel2;
    private javax.swing.JComboBox envsSelector;
    private javax.swing.JSeparator jSeparator1;
    private javax.swing.JButton loadDefaultFileButton;
    private javax.swing.JButton resetButton;
    private javax.swing.JButton runButton;
    private javax.swing.JButton runOneButton;
    private javax.swing.JButton stepButton;
    private javax.swing.JTextField stepTextField;
    private javax.swing.JLabel strategyLabel;
    private javax.swing.JLabel strategyLabel1;
    private javax.swing.JTextField timeLeftTextField;
    private javax.swing.JTextField timeTextField;
    private javax.swing.JCheckBox visualizeAgendaButton;
    private javax.swing.JCheckBox visualizeDebugButton;
    private javax.swing.JCheckBox visualizeFactsButton;
    // End of variables declaration//GEN-END:variables

    public JTextField getStepTextField() {
        return stepTextField;
    }

    public JTextField getTimeTextField() {
        return timeTextField;
    }
    
    public JTextField getLeftTimeTextField() {
        return this.timeLeftTextField;
    }

    public void setStepTextField(JTextField stepTextField) {
        this.stepTextField = stepTextField;
    }

    public void setTimeTextField(JTextField timeTextField) {
        this.timeTextField = timeTextField;
    }
    
    public void setLeftTimeTextField(JTextField timeLeftTextField) {
        this.timeLeftTextField = timeLeftTextField;
    }

    /**
     * Metodo per ottenere un'istanza del pannello di controllo
     *
     * @return il pannello di controllo racchiuso in un JPanel
     */
    public JPanel getControlPanel() {
        return controlPanel;
    }

    @Override
    public void update(Observable o, Object o1) {
        try {
            if (agendaMonitor.isVisible()) {
                agendaMonitor.setText(model.getAgenda());
            } else {
                visualizeAgendaButton.setSelected(false);
            }
            if (factsMonitor.isVisible()) {
                factsMonitor.setText(model.getFactList());
            } else {
                visualizeFactsButton.setSelected(false);
            }
            /**
             * Al termine dell'esecuzione vengono disabilitati tutti i pulsanti ad eccezione di quello di reset, perché inutili
             */
            String advice = (String) o1;
            if (advice.equals("disposeDone")) {
                if (runButton.getText().equals("Stop")) {
                    runButton.doClick();
                }
                this.runButton.setEnabled(false);
                this.runOneButton.setEnabled(false);
                this.stepButton.setEnabled(false);
                
            }
                
        } catch (Exception ex) {
            //System.out.println("[ERRORE] " + ex.toString());
            DebugFrame.appendText("[ERROR] " + ex.toString());
        }
    }

    /**
     * Estrae il nome di un file (con l'estensione) da un initialPath.
     *
     * @param initialPath un initialPath ad un file
     * @return una stringa contenente solo il nome del file
     */
    static private String filename(String path) {
        int i = path.lastIndexOf(File.separator);
        return path.substring(i + 1, path.length());
    }

    /**
     * Carica la lista delle strategie disponibili. L'informazione è ottenuta leggendo tutte le cartelle
     * contenute dentro la cartella CLP nella root del progetto. Ogni cartella contiene tutto il progetto
     * che implementa la relativa strategia.
     * @return  il combobox contenente tutte le strategie disponibili
     */
    private ComboBoxModel loadCLPFolderNames() {
    
        String path = System.getProperty("user.dir")+File.separator+"CLP";
        File folder = new File(path);
        DefaultComboBoxModel result = new DefaultComboBoxModel();
        File[] listOfFiles = folder.listFiles(); 
        for (File file : listOfFiles) {
            if (file.isDirectory() && !file.isHidden() && !file.getName().startsWith(".")) {
                result.addElement(file.getName());
            }
        }
        return result;
    }
    
    
        /**
     * Carica la lista degli environment disponibili. L'informazione è ottenuta leggendo tutte le cartelle
     * contenute dentro la cartella envs nella root del progetto. Ogni cartella contiene tutto il progetto
     * che implementa la relativa strategia e l'environment.
     * @return  Il modello per far sì che venga costruita il selector.
     */
    private ComboBoxModel loadEnvsFolderNames() {
    
        String path = System.getProperty("user.dir")+File.separator+"envs";
        File folder = new File(path);
        DefaultComboBoxModel result = new DefaultComboBoxModel();
        File[] listOfFiles = folder.listFiles(); 
        for (File file : listOfFiles) {
            if (file.isDirectory() && !file.isHidden() && !file.getName().startsWith(".")) {
                result.addElement(file.getName());
            }
        }
        return result;
    }
    
    

    private class ClpFileFilter extends FileFilter {

        @Override
        public boolean accept(File f) {
            if (f.isDirectory()) {
                return true;
            }
            String ext = null;
            String s = f.getName();
            int i = s.lastIndexOf('.');

            if (i > 0 && i < s.length() - 1) {
                ext = s.substring(i + 1).toLowerCase();
            }
            if (ext.equalsIgnoreCase("clp")) {
                return true;
            }
            return false;
        }

        @Override
        public String getDescription() {
            return "Clips files";
        }
    }    
}
