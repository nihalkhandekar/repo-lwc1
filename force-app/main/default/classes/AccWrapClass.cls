public class AccWrapClass {
public List<wrap> wc {get; set;}        // childclass/wrapclass ka variable bhi define krege main class me// 
public List<Account> accList{get; set;}
public AccWrapClass (){                // MainClassConstructor//
wc = new List<wrap>();                // Ab us wrap class ki list ko constructor me initiate krege//
accList = new List<Account> ();       // khali list wrapper class k andr if wala data store karne k liye//
for(Account acc : [select id, name, industry, type, phone from Account]){
    wc.add(new wrap (acc ));        // yha khali wraplist k andr data fill kiya hai usk liy wrap class k instance k andr acc add kiya hai//
    }
} 
//Wrapper class: class k andr class//
    public class wrap {
    public Account a {get; set;}       //Account k records wrapper me wrap krna hai isliye wrap class me obj initiate krege//
    public Boolean b{get; set;}        // ye boolean checkbox k liye bnaya hai//
    public wrap(Account c){                     //wrapclassConstructor//
    a = c; //a khali hai yha pr wrapper class me jjo bhi data aega usko a me dalege//
    b = false; //initial value of check box = false//
    }
    }
    // == ab ek method bnaege jisme selected checkbox wale records add ho jaege dusre table me == //
    
    public void selectRecord() {
     
    for(wrap ww: wc) {
    if(ww.b == true){
    accList.add(ww.a);
      }
     }
    }
}