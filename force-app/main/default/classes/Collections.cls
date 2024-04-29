public class Collections {
/*
 Types:
1- List
2- Set
3- Map

List: 
-->It is a ordered collection of elements.
-->Each elements of list has its own index for identification.
-->First element has zero(0) index position. 
-->List can be nested as well as multidimentional.

Methods:

1. Add(Single value); /Add(3, single value);
2. addall(second List); /addall(second Set);
3. equals(second List); {for comparing}
4. contains(Value Name); {Boolean -Y/N}
5. clone(); {to add a complete list elements in another list}
6. clear(); to clear all elements in the list
7. remove(index value); {we can remove any value by adding index value in remove method}
8. get(index value);
9. index of();
10. size();
11. sort();

Syntax:

	List<String> li = new List<String>;
	List<Integer> li = new List<Integer>;
	List<Account> li = new List<Account>;
	List<Student__c> li = new List<Student__c>;
	
	List<Contact> cLi = [select id, name from contact] {This is also a list. cLi will store records that have id and name from contact obj}
or
	List<Contact> li = new List<Contact>;
	li = [select id, name from contact]; 

*/
    //Now using collections i.e. list inside a method//
    
    public void method1(){
        //First List//
        List<string> li = new List<String>(); // empty list// 
    	li.add('rina');
        li.add('Nina');
    	li.add('Sheena');
    	li.add('Tina');
    	li.add('Jeena');
        li.add(0, 'Pooja'); // {for adding any value to a particular place(here 1st position i.e 0) write index value}//
        
        system.debug('Values of li:'+li); 

        //Second List//
        List<string> li2 = new List<String>(); // empty list// 
   		li2.add('Ramesh');
        li2.addall(li); //adding first list in second list//
        li2.add('Suresh');
        
        system.debug('Values of li2:'+li2); 

		li2=li.clone(); //to override the exiting values and replacing all values by a diff list//
        
        system.debug('Values of li2:'+li2); 
        
        //li2.clear();//
        system.debug('Values of li2:'+li2); 
      
        Boolean b;
        b=li2.equals(li);
        system.debug(b);

        b=li.contains('Pooja');
        system.debug(b);
        
        system.debug('Values of li:'+li.get(0)); //get method can be used directly in the debug//
		li.remove(0);//this cannot be used directly in the debug//
        system.debug(li);
        
        system.debug('Values of li:'+li.indexof('Tina')); //indexof method can be used directly in the debug//
        
        system.debug('Size of li:'+li.size()); //size method can be used directly in the debug//
        
        List<account> accList = new List<account>();
       accList = [Select id, name, rating from account where rating =: 'Hot'];
        system.debug(accList); // this will print unordered records//
        
        //to Iterate or to print records in ordered way like pointwise use for loop//
        for(Account acc : accList ){
            system.debug(acc);
        }
    }    

    
}