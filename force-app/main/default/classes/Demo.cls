public class Demo {

public String name{get; set;}
public List<String> AddList {get; set;}

    public Demo (){
    AddList = new List<String>();
    }
    
    public PageReference AddRecord(){
    AddList.add(name);
    Return null;
    }
    public PageReference RemoveRecord() {
    AddList.remove(AddList.size()-1);
    Return null;
    }

}