public class Test {
    public void integerList(){
List<Integer> integerList = new List<integer>{50,70,80,100} ;
for(Integer i = 0 ; i < integerList.size() ; i ++) {
for(integer j = i+1 ; j <= integerList.size() -1 ; j ++ ){
  integer x = 0 ;
  if(integerList[i] <  integerList[j]){
   x = integerList[i]  ;
   integerList[i] = integerList[j]  ;
   integerList[j]  = x;
  }
 }    
}
}
}