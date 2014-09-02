
import java.awt.Component;
import java.io.File;
import javax.swing.ButtonGroup;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.filechooser.FileFilter;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author toby
 */
public class MenuPannello extends JPanel {

    private javax.swing.JRadioButton drinkButton;
    private javax.swing.JRadioButton emptyButton;
    private javax.swing.JButton exportButton;
    private javax.swing.JRadioButton foodButton;
    private javax.swing.JButton loadButton;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JTextField nomeFileField;
    private javax.swing.JTextField num_col_field;
    private javax.swing.JTextField num_row_field;
    private javax.swing.JRadioButton parkingButton;
    private javax.swing.JRadioButton personButton;
    private javax.swing.JRadioButton recyclableButton;
    private javax.swing.JRadioButton seatButton;
    private javax.swing.JRadioButton tableButton;
    private javax.swing.JRadioButton trashButton;
    private javax.swing.JButton updateButton;
    private javax.swing.JRadioButton wallButton;
    private ScenePanel scenePanel;
    private JFileChooser fc;

    //variabile che tiene in memoria lo stato di selezione dei radiobutton per 
    //capire il significato dei numeri memorizzati all'interno vedere a inizio 
    //file scene
    private int state;
    private Component frame;

    public MenuPannello() {
        initComponents();
        state = 0;
    }

    private void initComponents() {
        fc = new JFileChooser();
        fc.setCurrentDirectory(new File("./"));
        fc.setFileFilter(new JSONFilter());

        jLabel1 = new javax.swing.JLabel();
        num_row_field = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        num_col_field = new javax.swing.JTextField();
        updateButton = new javax.swing.JButton();
        jLabel3 = new javax.swing.JLabel();
        nomeFileField = new javax.swing.JTextField();
        exportButton = new javax.swing.JButton();
        emptyButton = new javax.swing.JRadioButton();
        wallButton = new javax.swing.JRadioButton();
        seatButton = new javax.swing.JRadioButton();
        tableButton = new javax.swing.JRadioButton();
        recyclableButton = new javax.swing.JRadioButton();
        trashButton = new javax.swing.JRadioButton();
        foodButton = new javax.swing.JRadioButton();
        drinkButton = new javax.swing.JRadioButton();
        personButton = new javax.swing.JRadioButton();
        parkingButton = new javax.swing.JRadioButton();
        loadButton = new javax.swing.JButton();

        setPreferredSize(new java.awt.Dimension(280, 720));
        setSize(new java.awt.Dimension(280, 720));

        jLabel1.setText("Dimensioni griglia");

        num_row_field.setText("10");
        num_row_field.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                num_row_fieldActionPerformed(evt);
            }
        });

        jLabel2.setText("x");

        num_col_field.setText("10");
        num_col_field.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                num_col_fieldActionPerformed(evt);
            }
        });

        updateButton.setText("Aggiorna");
        updateButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                updateButtonActionPerformed(evt);
            }
        });

        jLabel3.setText("Inserisci");

        nomeFileField.setText("initMap");
        nomeFileField.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                nomeFileFieldActionPerformed(evt);
            }
        });

        exportButton.setText("Export");
        exportButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                exportButtonActionPerformed(evt);
            }
        });

        emptyButton.setText("Empty");
        emptyButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                emptyButtonActionPerformed(evt);
            }
        });

        wallButton.setText("Wall");
        wallButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                wallButtonActionPerformed(evt);
            }
        });

        seatButton.setText("Seat");
        seatButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                seatButtonActionPerformed(evt);
            }
        });

        tableButton.setText("Table");
        tableButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                tableButtonActionPerformed(evt);
            }
        });

        recyclableButton.setText("RB");
        recyclableButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                recyclableButtonActionPerformed(evt);
            }
        });

        trashButton.setText("TB");
        trashButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                trashButtonActionPerformed(evt);
            }
        });

        foodButton.setText("FD");
        foodButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                foodButtonActionPerformed(evt);
            }
        });

        drinkButton.setText("DD");
        drinkButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                drinkButtonActionPerformed(evt);
            }
        });

        personButton.setText("Parking");
        personButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                parkingButtonActionPerformed(evt);
            }
        });

        parkingButton.setText("Person");
        parkingButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                personButtonActionPerformed(evt);
            }
        });

        loadButton.setText("Load map");
        loadButton.addActionListener(new java.awt.event.ActionListener() {
            @Override
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                loadButtonActionPerformed(evt);
            }
        });
        
        //raggruppo i radio button per avere una mutua esclusione sulla selezione
        ButtonGroup gruppo = new ButtonGroup();
        gruppo.add(foodButton);
        gruppo.add(drinkButton);
        gruppo.add(personButton);
        gruppo.add(parkingButton);
        gruppo.add(trashButton);
        gruppo.add(tableButton);
        gruppo.add(seatButton);
        gruppo.add(wallButton);
        gruppo.add(emptyButton);
        gruppo.add(recyclableButton);

        emptyButton.setSelected(true);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
                layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(layout.createSequentialGroup()
                        .addGap(50, 50, 50)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                .addGroup(layout.createSequentialGroup()
                                        .addGap(41, 41, 41)
                                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                                                .addComponent(jLabel1)
                                                .addGroup(layout.createSequentialGroup()
                                                        .addComponent(num_row_field, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE)
                                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                        .addComponent(jLabel2)
                                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                                        .addComponent(num_col_field, javax.swing.GroupLayout.PREFERRED_SIZE, 40, javax.swing.GroupLayout.PREFERRED_SIZE))
                                                .addComponent(updateButton)
                                                .addComponent(jLabel3)
                                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                                        .addComponent(nomeFileField, javax.swing.GroupLayout.Alignment.TRAILING)
                                                        .addGroup(javax.swing.GroupLayout.Alignment.CENTER, layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                                                                .addComponent(exportButton)
                                                                .addComponent(loadButton))))
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 39, javax.swing.GroupLayout.PREFERRED_SIZE))
                                .addGroup(layout.createSequentialGroup()
                                        .addComponent(emptyButton)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(wallButton))
                                .addGroup(layout.createSequentialGroup()
                                        .addComponent(seatButton)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(tableButton))
                                .addGroup(layout.createSequentialGroup()
                                        .addComponent(recyclableButton)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(trashButton))
                                .addGroup(layout.createSequentialGroup()
                                        .addComponent(foodButton)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(drinkButton))
                                .addGroup(layout.createSequentialGroup()
                                        .addComponent(parkingButton)
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                                        .addComponent(personButton)))
                        .addGap(58, 58, 58))
        );
        layout.setVerticalGroup(
                layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(layout.createSequentialGroup()
                        .addGap(21, 21, 21)
                        .addComponent(jLabel1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(jLabel2)
                                .addComponent(num_col_field, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addComponent(num_row_field, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addComponent(updateButton)
                        .addGap(40, 40, 40)
                        .addComponent(jLabel3)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(emptyButton)
                                .addComponent(wallButton))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(seatButton)
                                .addComponent(tableButton))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(recyclableButton)
                                .addComponent(trashButton))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(foodButton)
                                .addComponent(drinkButton))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(parkingButton)
                                .addComponent(personButton))
                        .addGap(41, 41, 41)
                        .addComponent(nomeFileField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(exportButton)
                        .addGap(62, 62, 62)
                        .addComponent(loadButton)
                        .addContainerGap(188, Short.MAX_VALUE))
        );
    }

    private void num_row_fieldActionPerformed(java.awt.event.ActionEvent evt) {

    }

    private void num_col_fieldActionPerformed(java.awt.event.ActionEvent evt) {
    }

    private void updateButtonActionPerformed(java.awt.event.ActionEvent evt) {
        //controllo che l'input sia intero
        //leggo le nuove dimensioni della scena e le comunico al metodo 
        //resizeScene che si preoccuperà di ridimensionare la matrice mantenendo
        // i vecchi dati all'interno
        try {
            int num_row = Integer.parseInt(num_row_field.getText());
            int num_col = Integer.parseInt(num_col_field.getText());
            if (num_row > 0 && num_col > 0) {
                scenePanel.resizeScene(num_row, num_col);
            }
        } catch (NumberFormatException e) {
            this.errorMsg("Inserire valori naturali");
        }
    }

    private void emptyButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(0);
    }

    private void wallButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(1);
    }

    private void seatButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(2);
    }

    private void tableButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(3);
    }

    private void recyclableButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(4);
    }

    private void trashButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(5);
    }

    private void foodButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(6);
    }

    private void drinkButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(7);
    }

    private void personButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(8);
    }

    private void parkingButtonActionPerformed(java.awt.event.ActionEvent evt) {
        setState(9);
    }

    private void nomeFileFieldActionPerformed(java.awt.event.ActionEvent evt) {
        // TODO add your handling code here:
    }

    private void loadButtonActionPerformed(java.awt.event.ActionEvent evt) {
        int returnVal = fc.showOpenDialog(this);

        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = fc.getSelectedFile();
            Scene s = loader.read_mappa(file);
            scenePanel.updateScene(s);
        } 
    }

    private void exportButtonActionPerformed(java.awt.event.ActionEvent evt) {
        scenePanel.exportScene(nomeFileField.getText());
    }

    void init(ScenePanel scenePanel) {
        this.scenePanel = scenePanel;
    }

    int getState() {
        return state;
    }

    void setState(int i) {
        state = i;
    }

    String getNomeFile() {
        return this.nomeFileField.getText();
    }

    void errorMsg(String error) {
        JOptionPane.showMessageDialog(frame,
                error,
                "Input Error",
                JOptionPane.WARNING_MESSAGE);
    }

    void printMsg(String Msg) {
        JOptionPane.showMessageDialog(frame,
                Msg,
                "Message",
                JOptionPane.INFORMATION_MESSAGE);
    }

    private class JSONFilter extends FileFilter {

        @Override
        public boolean accept(File f) {
            return f.getName().toLowerCase().endsWith(".json") || f.isDirectory();
        }

        @Override
        public String getDescription() {
            return "JSON files (*.json)";
        }
    }
}
