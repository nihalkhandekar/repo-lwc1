public class CollectionSet {
            /*
      Set!! 
    Syntex of set:
    Set<id> st=new set<id>();
    Set<string> st=new set<string>();
    Set<integer> st=new set<integer>();
    
    Methods in set:
    1. Add(value);
    2. addall(second list); / addall(second set);
    3. equals(second set);
    4. contains(set value);
    5. containsall(second list); /  containsall(second set);
    6. clear();
    7. clone();
    8. isEmpty()
    9. Size();
    10. remove(value);
    11. removeall(second list); /  removeall(second set);
    
    
    */
	
    public void method2(){
          
        Set<String> s1 = new Set<String>();
		s1.add('Red');  
        s1.add('Green');            
		s1.add('Yellow');            
		s1.add('Blue');            
		s1.add('White');            
		system.debug(s1);
        
        Set<String> S2 = new Set<String>();
        s2.add('Black');
		s2.addAll(s1);
        system.debug('Value of s2:' +s2);
        
        boolean b, b1, b2, b3;
        b = s1.equals(s2);
        system.debug(b);
        
        b1 = s2.contains('Black');
        system.debug(b1);
        
        b2= s2.containsall(s1); //true cz s2 contains all s1 set value and one extra also //
        system.debug('ContainsAll:'+ b2 ); 
         
        s1.clear();
        system.debug('Value of s1 after Clear:'+ s1); 
		
        Set<string> s3 = new Set<string>();
        s3=s2.clone();
        system.debug('Value of s3 after clone with s2:'+ s2.clone());
        s3.add('purple');
        s3.add('Grey');
        s3.add('White'); // duplicate value from set 1
        s3.add('Brown');
		 
        b3 = s1.isEmpty();
        system.debug(b3); // this is true cz s1 got clear in line no. 50//
        
        system.debug('Size of s3 :'+ s3.size()); //size is 7 now cz added one string after s2 clone//
		
        s3.remove('purple');
        system.debug('Removing last colour purple from s3 :'+ s3);
        
        s3.removeall(s2);
        system.debug('After removeall method s3 will be:' +s3);
    }
}