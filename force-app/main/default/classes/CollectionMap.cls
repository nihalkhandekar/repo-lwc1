public class CollectionMap {
    public void method3(){
        Map<integer, string> mp = new Map<integer, string>();
        mp.put(1, 'India');
        mp.put(2, 'China');
        mp.put(3, 'Japan');
        mp.put(4, 'Australia');
        mp.put(5, 'Russia');
        mp.put(6, 'China');
        mp.put(7, 'China');
        mp.put(7, 'Ukraine');
        mp.put(3, 'South-Korea');

        system.debug('Values of Map are:' +mp);
        
        mp.remove(4);
        system.debug('Values of Map are:' +mp);
		      
        system.debug('Size of mp:' +mp.size());
        system.debug('Values of mp:' +mp.values());//this can also be printed in list as follows://
		
        list<String> li = new list<string>();
        li = mp.values();
        system.debug('Print the map values in list:' +li);
        
        Map<integer, string> mp1 = new Map<integer, string>();
		mp1=mp.clone();
        mp1.put(9, 'Canada');
        mp1.put(8, 'Mexico');        
        system.debug('Print the mp1 values :' +mp1);
        system.debug('Checking ContainsKey Method :' +mp1.containskey(8)); // this will return boolean output//
        system.debug('Checking get method :' +mp1.get(8));//This will return a value associated with the respective key//
		
        List<Account> accl1 = [select id, name from account];
        system.debug('Print the Acclist values :' +accl1);

        Map<ID, Account> AccMap = new Map<ID, Account>(accl1);
        system.debug('Print the AccMap values :' +AccMap);

    }
}