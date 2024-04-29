public class CollectionClass {
    public static void mapCollection(){
        list<integer> RandomNumber = new list<integer>{};
        RandomNumber.add(50);
        RandomNumber.add(60);
        RandomNumber.add(70);
        RandomNumber.add(80);
        RandomNumber.add(100);
        RandomNumber.sort();
        list<integer> DecendingOrderList = new list<integer>();

        for(integer i = RandomNumber.size()-1; i>=0; i--){
            DecendingOrderList.add(RandomNumber[i]);
        }
        system.debug(DecendingOrderList);
    }
    
}