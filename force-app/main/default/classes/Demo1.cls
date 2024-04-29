public class Demo1 {

public String name{get; set;}
public List<String> StrList {get; set;}
public List<integer> IntList {get; set;}
public Integer i{get; set;}

    public Demo1 (){
    StrList = new List<String>();
    IntList = new List<integer>();
    i=0;
    }
    //Add Button Method//
    public void AddRecord(){
    StrList.add(name);
    IntList.add(i);
    i++;
    }
    
    //Remove Button Method//
    public void RemoveRecord() {
    StrList.remove(i-1);
    IntList.remove(i-1);
    i--;
    }

}