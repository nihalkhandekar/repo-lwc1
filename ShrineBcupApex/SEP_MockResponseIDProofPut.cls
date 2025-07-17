/* DESCRIPTION: This is Test class for providing mock response for Put API call Id proofing     
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                          16-September-2021               Created First Version
***************************************************************************************************/
@isTest
global class SEP_MockResponseIDProofPut implements HttpCalloutMock{
    String sRequest;
    global SEP_MockResponseIDProofPut(String sRequest){
        this.sRequest = sRequest;
    }
        global HTTPResponse respond(HTTPRequest req) {
                if(sRequest == 'Failure'){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"Status":{"ConversationId":"310139","RequestId":"110309","TransactionStatus":"pending","ActionType":"aners","Reference":"RESTample","LexID":"209297"},"Products":[{"ProductType":"Velocity","ExecutedStepName":"pre_id_velocity","ProductConfigurationName":"customers.stateofct2_gaming_velocity_preid","ProductStatus":"pass","Items":[{"ItemName":"FUTILITY","ItemStatus":"pass"}]},{"ProductType":"Discovery","ExecutedStepName":"discovery","ProductConfigurationName":"customers.stateofct2_gaming_discovery","ProductStatus":"pass"},{"ProductType":"Velocity","ExecutedStepName":"post_id_velocity","ProductConfigurationName":"customers.stateofct2_gaming_velocity_postid","ProductStatus":"pass","Items":[{"ItemName":"FREQUENCY","ItemStatus":"pass"},{"ItemName":"QUIZ","ItemStatus":"pass"}]},{"ProductType":"IdentityEvent","ExecutedStepName":"identity_events","ProductConfigurationName":"customers.stateofct2_gaming_identity_events","ProductStatus":"pass"},{"ProductType":"IIDQA","ExecutedStepName":"authentication","ProductConfigurationName":"customers.stateofct2_gaming_authentication","ProductStatus":"pending","Items":[{"ItemName":"questionset.setnumber","ItemReason":{"Code":"1"},"ItemInformationDetails":[{"Key":"55:StudentCollegeCity_RedHerring","Name":"status","Value":"passed"},{"Key":"300:storical_RedHerring","Name":"status","Value":"passed"},{"Key":"11:Livet_RedHerring","Name":"status","Value":"failed"},{"Key":"questionset.count.total","Value":"3"},{"Key":"questionset.count.passed","Value":"2"}]}],"QuestionSet":{"QuestionSetId":2313759,"Questions":[{"QuestionId":3093859,"Key":121,"Type":"singlechoice","Text":{"Statement":"Based on  Gardens?"},"HelpText":{"Statement":"The ad variations from your actual address"},"Choices":[{"ChoiceId":59299,"Text":{"Statement":"Humdt"}},{"ChoiceId":5901309,"Text":{"Statement":"Iyo"}},{"ChoiceId":591319,"Text":{"Statement":"Kn"}},{"ChoiceId":5511329,"Text":{"Statement":"Orge"}},{"ChoiceId":5909339,"Text":{"Statement":"this address"}}]}]}}]}');
                res.setStatusCode(200);
                return res;
            }else{
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"mulesoft down"}');
                res.setStatusCode(503);
                return res;
            }
        }
}