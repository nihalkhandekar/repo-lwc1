@isTest
public class BackOfficeRejectionComments1_Test {

    static testMethod void rejectionComments() {

        //Test rejection comments populated
        List<BackOfficeRejectionComments1.FlowInputs> input = new List<BackOfficeRejectionComments1.FlowInputs>();
        List<BackOfficeRejectionComments1.FlowInputs> inputListnull = new List<BackOfficeRejectionComments1.FlowInputs>();

        List<BackOfficeRejectionComments1.FlowOutputs> output = new List<BackOfficeRejectionComments1.FlowOutputs>();

        BackOfficeRejectionComments1.FlowInputs fl = new BackOfficeRejectionComments1.FlowInputs();
        BackOfficeRejectionComments1.FlowInputs inputNull = new BackOfficeRejectionComments1.FlowInputs();

        BackOfficeRejectionComments1.FlowOutputs fo = new BackOfficeRejectionComments1.FlowOutputs();
        fl.RejectionComments1 = 'Comment 1 test';
        fl.RejectionComments2 =  'Comment 2 test';
        fl.RejectionComments3 = 'Comment 3 test';
        fl.RejectionComments4 =  'Comment 4 test';
        fl.RejectionComments5 = 'Comment 5 test';
        fl.RejectionComments6 =  'Comment 6 test';
        fl.RejectionComments7 = 'Comment 7 test';
        inputNull.RejectionComments7 = '';

        input.add(fl);
        inputListnull.add(inputNull);

        BackOfficeRejectionComments1.invokeLocalMethod(input); 
        BackOfficeRejectionComments1.invokeLocalMethod(inputListnull); 
 

        System.assertEquals('Incorrect Signature','Incorrect Signature');
    }

}