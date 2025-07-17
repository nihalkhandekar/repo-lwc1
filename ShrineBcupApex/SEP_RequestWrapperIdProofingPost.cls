/* DESCRIPTION:  Wrapper Class used to generate the Post request for ID Proofing 
*
* @AUTHOR: 	Ankit Singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                           9-September-2021                    Created First Version
***************************************************************************************************/
public with sharing class SEP_RequestWrapperIdProofingPost {

    public String Type; 
	public Settings Settings; 
	public List<Persons> Persons; 
    
    public SEP_RequestWrapperIdProofingPost(String Type,Settings Settings,List<Persons> Persons){
        this.Type = Type;
        this.Settings = Settings;
        this.Persons = Persons;
    } 

    public class Settings {
		public String Mode ; 
		public String Reference ; 
		public String Locale ; 
		public String Venue ;
        
        public Settings(String Mode,String Reference,String Locale,String Venue){
            this.Mode = Mode;
            this.Reference = Reference; 
            this.Locale = Locale; 
            this.Venue = Venue;  
        }
    }

    public class Persons {
		public Name Name ; 
		public List<Addresses> Addresses ; 
		public SSN SSN ; 
		public DateOfBirth DateOfBirth ; 
		public List<Phones> Phones ; 
		public String Context ; 

        public Persons(Name Name,List<Addresses> Addresses,SSN SSN,DateOfBirth DateOfBirth,List<Phones> Phones,String Context){
            this.Name = Name;
            this.Phones = Phones;
            this.SSN = SSN;
            this.DateOfBirth = DateOfBirth;
            this.Context = Context;
            this.Addresses = Addresses;

        }

    }	

    public class Addresses {
		public String StreetAddress1 ; 
		public String City ; 
		public String State ; 
		public String Zip5 ; 
		public String Country ; 
		public String Context ;

        public Addresses(String StreetAddress1,String City,String State,String Zip5,String Country,String Context){
        this.StreetAddress1 = StreetAddress1;
        this.City = City;
        this.State = State;
        this.Zip5 = Zip5;
        this.Country = Country;
        this.Context = Context;
        }
    }
	
	public class DateOfBirth {
		public String Year ; 
		public String Month ; 
		public String Day ; 

        public DateOfBirth(String Year,String Month,String Day){
        this.Year = Year;
        this.Month = Month;
        this.Day = Day;
        }
    }
	
	public class Phones {
	public String PNumber ; // in json: Number
	public String Context ;
    
    public Phones(String PNumber,String Context){
    this.PNumber = PNumber;
    this.Context = Context;
    }
    
    }	
	
	public class Name {
		public String FirstName ; 
		public String LastName ; 

        public Name(String FirstName,String LastName){
        this.FirstName = FirstName;
        this.LastName = LastName;
        }
    }
		
	public class SSN {
		public String SSNumber ; // in json: Number
		public String Type ; 

        public SSN(String SSNumber,String Type){
        this.SSNumber = SSNumber;
        this.Type = Type;
        }
    }		
}