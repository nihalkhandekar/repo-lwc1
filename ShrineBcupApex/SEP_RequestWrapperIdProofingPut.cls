/* DESCRIPTION:  Wrapper Class used to generate the Put request for ID Proofing 
*
* @AUTHOR: 	Ankit Singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                           9-September-2021                    Created First Version
***************************************************************************************************/
public with sharing class SEP_RequestWrapperIdProofingPut {
   
	public String Type;
	public Settings Settings;
	public Answers Answers;
   
    public SEP_RequestWrapperIdProofingPut(String Type,Settings Settings,Answers Answers){
    this.Type = Type;
    this.Settings = Settings;
    this.Answers = Answers;
    }

    public class Answers {
		public Long QuestionSetId;
		public List<Questions> Questions;

        public Answers(Long QuestionSetId,List<Questions> Questions){
        this.QuestionSetId = QuestionSetId;
        this.Questions = Questions;
        }
	}

	public class Choices {
		public String Choice;

        public Choices(String Choice){
        this.Choice = Choice;
        }
	}

	public class Questions {
		public Long QuestionId;
		public List<Choices> Choices;

        public Questions(Long QuestionId,List<Choices> Choices){
        this.QuestionId = QuestionId;
        this.Choices = Choices;
        }
	}

	public class Settings {
		public String Mode;
		public String Reference;
		public String Locale;
		public String Venue;

        public Settings(String Mode,String Reference,String Locale,String Venue){
        this.Mode = Mode;
        this.Reference = Reference;
        this.Locale = Locale;
        this.Venue = Venue;
        }
	}

}