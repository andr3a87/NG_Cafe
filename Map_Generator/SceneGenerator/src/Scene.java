
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
/*

 0 = empty
 1 = wall
 2 = seat
 3 = table
 4 = RecyclableBasket
 5 = trashbasket
 6 = food dispenser
 7 = drink dispenser
 8 = person
 9 = parking
 10 = seat + person

 */

public class Scene {

    //numero di celle sulle x e sulle y
    int num_x, num_y;

    //largezza e altezza celle
    float c_width, c_height;
    //largezza e altezza finestra
    float w_width, w_height;

    //matrice fondamentale rappresentante la scena 
    int[][] scene;

    //percentuale della finestra che viene occupata dalla scena
    int perc;

    //array di immagini da disegnare sulla scena sono nello stesso ordine dello 
    //schema di valori della scena però traslato di -1 visto che per le celle 
    //empty non bisogna disegnare nulla
    //cioè in 0 c'è wall (1), in 1 c'è seat (2), e cosi via 
    BufferedImage[] images;

    public Scene() {
        
    }

    public Scene(int num_x, int num_y, float w_width, float w_height) {
        this.w_width = w_width;
        this.w_height = w_height;
        scene = new int[num_x][num_y];
        //genero la scena della dimensione specificata
        this.resize(num_x, num_y);
        //inizializzo la scena con i valori di default e cioè con i muri su tutto il bordo della scena
        this.initScene(scene);
        //carico tutte le image in ram
        this.loadImages();
    }

    public void loadImages() {
        images = new BufferedImage[10];
        try {
            images[0] = ImageIO.read(new File("./img/wall.jpeg"));
            images[1] = ImageIO.read(new File("./img/seat.jpg"));
            images[2] = ImageIO.read(new File("./img/table.jpeg"));
            images[3] = ImageIO.read(new File("./img/rb.jpeg"));
            images[4] = ImageIO.read(new File("./img/tb.jpeg"));
            images[5] = ImageIO.read(new File("./img/fd.jpeg"));
            images[6] = ImageIO.read(new File("./img/dd.jpg"));
            images[7] = ImageIO.read(new File("./img/seated.png"));
            images[8] = ImageIO.read(new File("./img/parking.jpeg"));
        } catch (IOException ex) {
            Logger.getLogger(Scene.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    public void drawScene(Graphics2D g) {
        //calcolo le coordinate di inizio della scena partendo a disegnare 
        //dall'angolo in alto a sinistra della nostra scena
        float x0 = (w_width - c_width * num_x) / 2;
        float y0 = (w_height - c_height * num_y) / 2;

        g.setColor(Color.BLACK);

        //doppio ciclo sulla matrice
        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                //calcolo la posizione x,y dell'angolo in alto a sinistra della 
                //cella corrente
                int x = (int) (x0 + i * c_width);
                int y = (int) (y0 + j * c_height);
                //se la cella non è vuota, allora disegno l'immagine corrispondente
                if (scene[i][j] > 0) {
                    g.drawImage(images[scene[i][j] - 1], x, y, (int) (c_width - 1), (int) (c_height - 1), null);
                }

                //traccio il rettangolo della cella
                g.drawRect(x, y, (int) (c_width - 1), (int) (c_height - 1));
            }
        }
    }

    public void resize(int num_x, int num_y) {
        //creo una scena con la nuova dimensione
        int[][] new_scene = new int[num_x][num_y];
        //percentuale che la scena al massimo o sulle x o sulle y può occupare
        perc = 90;
        //salvo il numero di celle sulle x e sulle y
        this.num_x = num_x;
        this.num_y = num_y;
        //calcolo la larghezza delle celle
        c_width = (w_width * perc / 100) / num_x;
        c_height = (w_height * perc / 100) / num_y;

        if (c_width > c_height) {
            c_width = c_height;
        } else {
            c_height = c_width;
        }

        initScene(new_scene);
        for (int i = 1; i < new_scene.length - 1; i++) {
            for (int j = 1; j < new_scene[i].length - 1; j++) {
                if (i <= scene.length - 1 && j <= scene[0].length - 1) {
                    new_scene[i][j] = scene[i][j];
                }
            }
        }
        scene = new_scene;
    }

    public void initScene(int[][] scene) {

        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                if (i == 0 || i == scene.length - 1 || j == 0 || j == scene[0].length - 1) {
                    scene[i][j] = 1;
                }
            }
        }
    }

    String exportHistory() {
        String history = "";
        int count = 1;
        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                if (scene[i][j] == 8) {  //controllo che la cella contenga una persona
                    history += "\n(personstatus\n\t(step 0)\n\t(time 0)\n\t(ident C" + count + ")\n";
                    history += "\t(pos-r " + (scene[i].length - j) + ")\n";
                    history += "\t(pos-c " + (i + 1) + ")\n";
                    history += "\t(activity seated)\n)\n";
                    count++;
                }
            }
        }
        return history;
    }

    public String exportScene() {
        String map = "(maxduration 100)\n";

        //variabili per impostare la posizione delle componenti
        int[] pos_agent = new int[2];

        //posizione dei vari componenti della mappa
        ArrayList<int[]> tavoli = new ArrayList<>();
        ArrayList<int[]> food = new ArrayList<>();
        ArrayList<int[]> drink = new ArrayList<>();
        ArrayList<int[]> recyclable = new ArrayList<>();
        ArrayList<int[]> trash = new ArrayList<>();

        String s = "";
        //Scansione della matrice di celle
        for (int i = 0; i < scene.length; i++) {
            for (int j = 0; j < scene[i].length; j++) {
                switch (scene[i][j]) {
                    case 0:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Empty))\n";
                        break;
                    case 1:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Wall))\n";
                        break;
                    case 2:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Seat))\n";
                        break;
                    case 3:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Table))\n";
                        int[] t = {(scene[i].length - j), (i + 1)};       //aggiungo agli array di tavoli trovati
                        tavoli.add(t);
                        break;
                    case 4:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains RB))\n";
                        int[] r = {(scene[i].length - j), (i + 1)};
                        recyclable.add(r);
                        break;
                    case 5:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains TB))\n";
                        int[] tr = {(scene[i].length - j), (i + 1)};
                        trash.add(tr);
                        break;
                    case 6:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains FD))\n";
                        int[] f = {(scene[i].length - j), (i + 1)};
                        food.add(f);
                        break;
                    case 7:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains DD))\n";
                        int[] dr = {(scene[i].length - j), (i + 1)};
                        drink.add(dr);
                        break;
                    case 8:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Seat))\n";
                        break;
                    case 9:
                        s += "(prior-cell (pos-r " + (scene[i].length - j) + ") (pos-c " + (i + 1) + ") (contains Parking))\n";
                        pos_agent[0] = (scene[i].length - j);
                        pos_agent[1] = (i + 1);
                        break;
                }
            }
        }

        //costuisco la string da salvare sul file
        //1. Posizione del agente all'inizio - Parking
        map += "\n(initial_agentposition (pos-r " + pos_agent[0] + ") (pos-c " + pos_agent[1] + ") (direction south))\n";

        //2. Posizione dei tavoli
        int count = 1;
        for (int[] t : tavoli) {
            map += "(Table (table-id T" + count + ") (pos-r " + t[0] + ") (pos-c " + t[1] + "))\n";
            count++;
        }
        count = 1;

        //3. Posizione dei trash
        for (int[] tr : trash) {
            map += "(TrashBasket (TB-id TB" + count + ") (pos-r " + tr[0] + ") (pos-c " + tr[1] + "))\n";
            count++;
        }
        count = 1;

        //4. Posizione dei Recyclable
        for (int[] rc : recyclable) {
            map += "(RecyclableBasket (RB-id RB" + count + ") (pos-r " + rc[0] + ") (pos-c " + rc[1] + "))\n";
            count++;
        }
        count = 1;

        //5. Posizione dei food
        for (int[] fd : food) {
            map += "(FoodDispenser  (FD-id FD" + count + ") (pos-r " + fd[0] + ") (pos-c " + fd[1] + "))\n";
            count++;
        }
        count = 1;

        //6. Posizione dei drink
        for (int[] dr : drink) {
            map += "(DrinkDispenser  (DD-id DD" + count + ") (pos-r " + dr[0] + ") (pos-c " + dr[1] + "))\n";
            count++;
        }

        //concateno con la definizione delle celle;
        map += "\n" + s;
        return map;
    }

    String click(int x, int y, int state) {
        float x0 = (w_width - c_width * num_x) / 2;
        float y0 = (w_height - c_height * num_y) / 2;
        float cordx = x - x0;
        float cordy = y - y0;
        cordx = cordx / c_width;
        cordy = cordy / c_height;
        int i = (int) cordx;
        int j = (int) cordy;
        String result = "success";
        if (i >= 0 && i < num_x
                && j >= 0 && j < num_y) {
            if (state == 8 && scene[i][j] == 2) {
                scene[i][j] = 8;
            } else if (state == 8 && scene[i][j] != 2) {
                result = "Una persona può essere aggiunta solo su una sedia.";
            } else {
                scene[i][j] = state;
            }
        } else {
            result = "Hai cliccato fuori dalla scena.";
        }
        return result;
    }

    public void setNumCelle(int num_x, int num_y) {
        this.num_x = num_x;
        this.num_y = num_y;
        scene = new int[num_x][num_y];
    }

    public void setCella(int x, int y, int value) {
        scene[x][y] = value;
    }
    
    public void setSizeScreen(float w_width, float w_height){
        this.w_height=w_height;
        this.w_width = w_width;
    }
}
