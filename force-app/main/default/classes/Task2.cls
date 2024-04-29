public class Task2 {

// Global Variables//
public integer empId;
public string name;
public string address;
public integer phone;
public decimal salary;
public decimal price;
public decimal TotalCost;
public decimal SellingPrice;
public decimal PerUnitPrice;
public string DOB;
public boolean PermanentEmployee;

//Constructor//    
  public Task2() {
    system.debug('welcome');
    Task2 tk21 = new Task2(2000, 3000);
    Task2 tk22 = new Task2('Ram', 'Shyam');
    Task2 tk23 = new Task2('Laxman');
    tk23.salary=4000;
    tk23.method1();
    tk23.method2(4000);
    tk23.multiplication(1000);
    tk23.Division(5000);
    tk23.Subtraction(3000);
    } 
  public Task2(integer a, integer a1) {
    system.debug('welcome returns');
    }  
  public Task2(string a3, string a4) {
    system.debug('welcome back');
    } 
  public Task2(string a7) {
    system.debug('Not welcome');
    }
    
  // Methods //
  public void method1(){           //Non-Returnable//
  decimal incentive;           //Local Variable-Incentive-------default private//
  incentive = Salary+2000;     //receiver left side & giver right side //
  system.debug('Value of incentive'+ incentive);       
  }
  public decimal method2(decimal a){ //Returnable//
  decimal incentive;
  salary = a;
  incentive = salary + 4000;
  system.debug('New Value of Incentive:' + incentive);
  return incentive;
  }  
  public decimal multiplication(decimal b){
  decimal price;
  price = b;
  TotalCost = price * 2;
  system.debug('Value of total cost:'+ TotalCost);
  return TotalCost;
  }
  public decimal Division(decimal c){
  decimal TotalPrice;
  TotalPrice = c;
  PerunitPrice = TotalPrice/2;
  system.debug('Value of Per unit price:'+ PerunitPrice);
  return PerunitPrice;
  }
  public decimal Subtraction(decimal d){
  decimal MarketPrice;
  MarketPrice = d;
  SellingPrice = MarketPrice - 100;
  system.debug('Value of Selling Price:'+ SellingPrice);
  return SellingPrice;
  }
}