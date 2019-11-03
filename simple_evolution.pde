static final int NUMBER_OF_CREATURES = 10;
static final int NUMBER_OF_MEALS = 500;

static final float INITIAL_FOOD_SENSE = 100;
static final float INTIIAL_ENERGY = 50;

float calculateMoveCost(Creature c) {
  float cost = (c.movement.speed * 2 + c.body.size*3)/100;
  return cost;
}

class Metric {
  float sum = 0;
  float max = Integer.MIN_VALUE;
  float min = Integer.MAX_VALUE;
  int hits = 0;

  float getAverage() {
    return sum/hits;
  }

  void put(float value) {
    this.sum+=value;
    if (value > max) { 
      max = value;
    }

    if (value < min) {
      min = value;
    }
    hits++;
  }

  String toString() {
    return sum + "," + min + "," + ","+max+","+hits;
  }
  String toPrettyString(String label) {
    return label +"[" + "MAX: " + max + " MIN:" + min + " AVG:" + getAverage() + "]";
  }
}
class Body {
  color intialC;
  color c;
  float size;
  float x, y;
  Body(color c, float size, float x, float y) {
    this.c = c;
    this.intialC = c;
    this.size = size;
    this.x = x;
    this.y = y;
  }

  void move(Movement m) {
    this.x = this.x + (m.speed * cos(m.getAngleInRadians()));
    this.y = this.y + (m.speed * sin(m.getAngleInRadians()));
  }

  float move(Movement m, float energyFactor) {
    move(m);
    return m.speed * energyFactor;
  }


  void draw() {
    fill(c);
    ellipse(x, y, size, size);
  }

  float distanceTo(Body b) {
    return sqrt(pow(x - b.x, 2) + pow(y - b.y, 2));
  }

  Body evolve(float probability) {
    float r = 0.5f - random(1);
    if (r >= -probability && r < 0) {
      return new Body(
        this.intialC, 
        size - (random(1) * size/2), 
        this.x, 
        this.y
        );
    } else if (r >= 0 && r < probability) {
      return new Body(
        this.intialC, 
        size + (random(1) * size/2), 
        this.x, 
        this.y
        );
    } else {
      return new Body(
        this.c, this.size, this.x, this.y);
    }
  }
}

class Meal {
  Body body;
  Food food;

  Meal(Body body, Food food) {
    this.body = body;
    this.food = food;
  }

  void draw() {
    this.body.draw();
  }

  Creature canBeEaten(ArrayList<Creature> creatures) {
    for (Creature c : creatures) {
      if (body.distanceTo(c.body) < c.body.size) {
        return c;
      }
    }
    return null;
  }
}
class Movement {
  float speed;
  float angle;

  Movement(float speed, float angle) {
    this.speed = speed;
    this.angle = angle;
  }

  float getAngleInRadians() {
    return angle * PI/180;
  }

  Movement evolve(float probability) {
    float r = 0.5f - random(1);
    if (r >= -probability && r < 0) {
      return new Movement(
        this.speed - (random(1) * speed/2), 
        0);
    } else if (r >= 0 && r < probability) {
      return new Movement(
        this.speed + (random(1) * speed/2), 
        0);
    } else {
      return new Movement(this.speed, 0);
    }
  }
}

class Food {
  float energy;
  float initialEnergy;
  Food(float energy) {
    this.energy = energy;
    this.initialEnergy = energy;
  }

  void use(float howMuch) {
    this.energy -= howMuch;
    if (this.energy < 0) {
      this.energy = 0;
    }
  }
}

class FoodSense {
  float range;

  FoodSense(float range) {
    this.range = range;
  }

  FoodSense evolve(float probability) {
    float r = 0.5f - random(1);
    if (r >= -probability && r < 0) {
      return new FoodSense(range - (random(1) * range/2));
    } else if (r >= 0 && r < probability) {
      return new FoodSense(range + (random(1) * range/2));
    } else {
      return new FoodSense(range);
    }
  }

  Float sense(Body position, ArrayList<Meal> meals) {
    for (Meal m : meals) {
      if (position.distanceTo(m.body) <= range/2) {
        float y = (m.body.y - position.y);
        float x = (m.body.x - position.x);
        float newAngle = atan2(y, x);
        m.body.c = color(0, 0, 255);
        return newAngle * 180 / PI;
      }
    }
    return null;
  }
}
class Creature {
  Body body;
  Movement movement;
  Food food;
  FoodSense foodSense;
  int mealsCollected;
  int lifetime;
  int offspring;
  Creature(
    Body body, 
    Movement movement, 
    Food food, 
    FoodSense foodSense) {
    this.body = body;
    this.movement = movement;
    this.food = food;
    this.foodSense=foodSense;
    this.mealsCollected = 0;
    this.lifetime = 0;
    this.offspring=0;
  }

  void draw() {
    noFill();
    stroke(255, 255, 0);
    ellipse(this.body.x, this.body.y, this.foodSense.range, this.foodSense.range);
    float normalizedSpeed = movement.speed/(speedMetric.max - speedMetric.min);
    stroke(255 * normalizedSpeed, 0, 0);
    this.body.draw();
        stroke(0, 0, 0);
  }

  boolean isAlive() {
    return this.food.energy > 0;
  }

  void move() {
    if (isAlive()) {
      float energyFactorDiv = 10000- creatures.size()*creatures.size();
      energyFactorDiv = energyFactorDiv > 0? energyFactorDiv:1;
      this.body.move(this.movement);
      this.food.use(calculateMoveCost(this));
    }
  }

  void setDirection(float angle_in_degress) {
    this.movement.angle = angle_in_degress;
  }

  float getDirection() {
    return this.movement.angle;
  }

  void changeAngle() {
    float m = random(1);
    if ( m < 0.33f) {
      setDirection(getDirection() + 12);
    } else if (m > 0.67f) {
      setDirection(getDirection() - 12);
    }
  }
  void revertIfNeeded() {
    if (body.x < 0) {
      body.x = 1280;
    }

    if (body.x > 1280) {
      body.x = 0;
    }
    if (body.y < 0) {
      body.y = 800;
    }

    if (body.y > 800) {
      body.y = 0;
    }
  }

  void changeColor() {
    int b = body.intialC & 0xFF; 
    float factor = (food.energy / food.initialEnergy) > 1 ? 1 : (food.energy / food.initialEnergy);
    color newColor =  color(
      (int)(255 * factor), 
      (int)(255 * factor), 
      b
      );
    body.c = newColor;
  }

  Creature evolve(float probability) {   
    return new Creature(
      this.body.evolve(probability), 
      this.movement.evolve(probability), 
      new Food(this.food.initialEnergy), 
      this.foodSense.evolve(probability));
  }
  void doLive() {
    move();
    Float angle = this.foodSense.sense(this.body, meals);
    if (angle != null) {
      movement.angle = angle;
    } else {
      changeAngle();
    }
    revertIfNeeded();

    changeColor();
    lifetime++;
  }
}

ArrayList<Creature> creatures;
ArrayList<Meal> meals;
ArrayList<Meal> toRemove = new ArrayList();
ArrayList<Meal> mealsToAdd = new ArrayList();
ArrayList<Creature> creaturesToRemove = new ArrayList();
ArrayList<Creature> creaturesToAdd = new ArrayList();

Metric speedMetric = new Metric();
PrintWriter outputData = createWriter("output.txt");

void collectMertics() {
  speedMetric = new Metric();
  Metric sizeMetric = new Metric();
  Metric energyMetric = new Metric();
  Metric foodSenseMetric = new Metric();
  Metric lifetimeMetric = new Metric();
  Metric offspringMetric = new Metric();
  for (int i =0; i < creatures.size(); i++) {
    speedMetric.put(creatures.get(i).movement.speed);
    sizeMetric.put(creatures.get(i).body.size);
    energyMetric.put(creatures.get(i).food.energy);
    foodSenseMetric.put(creatures.get(i).foodSense.range);
    lifetimeMetric.put(creatures.get(i).lifetime);
    offspringMetric.put(creatures.get(i).offspring);
  }
  println(
    "Tick: " + (tick++) + 
    ", Creatures: " + creatures.size() + 
    ", Meals :" + meals.size() + 
    "\n Speed: " + speedMetric.toPrettyString("Speed") + 
    "\n Size: " + sizeMetric.toPrettyString("Size") + 
    "\n Energy: " + energyMetric.toPrettyString("Energy") +
    "\n FoodSense: " + foodSenseMetric.toPrettyString("FoodSense") +
    "\n Lifetime:" + lifetimeMetric.toPrettyString("Lifetime") + 
    "\n Offspring:" + offspringMetric.toPrettyString("Offspring"));
}
void setup() {
  size(1280, 800);
  creatures = new ArrayList(NUMBER_OF_CREATURES);
  for (int i = 0; i < NUMBER_OF_CREATURES; i++) {
    Creature  c = new Creature(
      new Body(color(0, 0, 255), 20, 640, 400), 
      new Movement(5, 0 + (90 * (i%4))), 
      new Food(INTIIAL_ENERGY), 
      new FoodSense(INITIAL_FOOD_SENSE));
    creatures.add(c);
  }

  meals = new ArrayList(NUMBER_OF_MEALS);
  for (int i = 0; i < NUMBER_OF_MEALS; i++) {
    Meal m = new Meal(
      new Body(color(255, 0, 0), 5, random(1280), random(800)), 
      new Food(random(50)));
    meals.add(m);
  }
}

long tick = 1;
void draw() {
  background(100, 255, 100);
  for (Creature c : creatures) {
    c.doLive();
    if (c.isAlive()) {
      c.draw();
    } else {
      creaturesToRemove.add(c);
      for (int z = 0; z < 2; z++) {
        Meal m = new Meal(
          new Body(color(255, 0, 0), 5, random(1280), random(800)), 
          new Food(c.food.initialEnergy));
        mealsToAdd.add(m);
      }
    }
    if (c.mealsCollected > 1) {
      creaturesToAdd.add(c.evolve(0.05f));
      c.mealsCollected = 0;
      c.offspring++;
    }
  }

  creatures.removeAll(creaturesToRemove);   
  creatures.addAll(creaturesToAdd);

  for (Meal m : meals) {
    m.draw(); 
    Creature eater = m.canBeEaten(creatures);
    if (eater != null) {
      eater.food.energy += m.food.energy;
      eater.mealsCollected++;
      toRemove.add(m);
    }
  }
  meals.removeAll(toRemove);
  meals.addAll(mealsToAdd);
  toRemove.clear();
  creaturesToRemove.clear();
  creaturesToAdd.clear();
  mealsToAdd.clear();

  collectMertics();

  if ( (creatures.size() < 2 && tick > 1000) || tick > 500000) {
    System.exit(0);
  }
}
