# Java OOP

1. Class:  Group of similar entities(logically)

   ````java
   public class Vehicle{
       private String name;
       private String kind;
      
       public work(){
           System.out.println("Vehicle is working")
       }
   }
   ````

   

2. Object:  Instance of a class, and there can be multiple instances of a class in a program

   ````java
   Car BMW =new Car();
   Car Toyota= new Toyota();
   ````

3. Inheritance: One object acquires the properties and behaviors of the parent object.

   ````java
   public class Car extends Vehicle {
     private Long price;  
   
   	public staic void main (String ... args){
       	Car car = new Vehicle(); // ???
           car.work();
           Vehicle vehicle= new Car(); ///??
           vehicle.work();
   	}
   }
   ````

   ````java
   
   class A1 {
       A1(int a , int b){
   		System.out.println("Call constructor inside thr class A1"); 
       }
       A1 foo()
       {  
           return this;  
       }  
         
       void print()  
       {  
           System.out.println("Inside the class A1");  
       }
   
   }
   class A2 extends A1 {
       A2() {
           super(10,20);
       }
   
       @Override
       A2 foo()
       {  
           return this;  
       }  
         
       void print()  
       {  
           System.out.println("Inside the class A2");  
       }
       void a2Method(){
           System.out.println("call a2 method");
       }
   }  
   ````

   The `Object` class is **the superclass of all other classes in Java** and a part of the built-in java. `lang` package. If a parent class isn't specified using the extends keyword, the class will inherit from the Object class.

4. Polymorphism: **perform the same action in many different ways**

   1. **Method Overloading** or **Compile-Time** Polymorphism

      ````java
      class Shapes {
        public void area() {
          System.out.println("Find area ");
        }
      public void area(int r) {
          System.out.println("Circle area = "+3.14*r*r);
        }
       
      public void area(double b, double h) {
          System.out.println("Triangle area="+0.5*b*h);
        }
      public void area(int l, int b) {
          System.out.println("Rectangle area="+l*b);
        }
       
       
      }
       
      class Main {
        public static void main(String[] args) {
          Shapes myShape = new Shapes();  // Create a Shapes object
           
          myShape.area();
          myShape.area(5);
          myShape.area(6.0,1.2);
          myShape.area(6,2);
           
        }
      }
      ````

      

   2. Method Overriding: Method overriding is defined as a process when the subclass or a child class has the same method as declared in the parent class.

   ````java
   class Vehicle{  
     //defining a method  
     void run(){System.out.println("Vehicle is moving");}  
   }  
   //Creating a child class  
   class Car extends Vehicle{  
     //defining the same method as in the parent class  
       @Override
     void run(){System.out.println("car is running safely");}  
   }
   class Bike extends Vehile{
           @Override
     void run(){System.out.println("bike is running safely");}  
   }
   pulic class Test
     
     public static void main(String args[]){  
     Car obj = new Car();//creating object  
     obj.run();//calling method  
     
       Vehicle v=new Car()
           v.run(); //car is running safely .Runtime polymorphism in java is also known as Dynamic Binding or Dynamic Method Dispatch. 
       
     }  
   }  
   
   ````

   

5. Abstraction and interface : We can not make instance directly 

   ````java
   pubic abstract class ToyotaCar{
       public void start(){
           System.out.println("start working");
       }
       public abstract preapreCar();
   }
   public interface Vehicle{
       void start();
       void stop();
       void fix(Logn takeTime);
       void handleCrash(Person person);
   }
   ````

   - When we talk about abstract classes we are defining characteristics of an object type; specifying ***what an object is\***.
   - When we talk about an interface and define capabilities that we promise to provide, we are talking about establishing a contract about **what the object can do**
   - **Interfaces** do not express something like "a Doberman is a type of dog and every dog can walk" but more like "this thing can walk"

6. Encapsulation

7. Association

8. Aggregation

9. Composition

# Primitive and Wrapper class and convert together 

# Java anonymous class

# Java enums



# Java Inner Class



# Java Generic

- *Unbounded Wildcards*: *List<?>* represents a list of unknown type
- *Upper Bounded Wildcards*: *List<? extends Number>* represents a list of *Number* or its sub-types such as *Integer* and *Double*
- *Lower Bounded Wildcards*: *List<? super Integer>* represents a list of *Integer* or its super-types *Number* and *Object*
- https://www.baeldung.com/java-generics-vs-extends-object









# Java Function

## Consumer & Supplier & predication ,...



# Java Lambda



# Java Stream



# Java Collection

# Java list builder 



