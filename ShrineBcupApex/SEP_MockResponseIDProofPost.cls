/* DESCRIPTION: This is Test class for providing mock response for Post API call Id proofing     
*
* @AUTHOR: 	Ankit singh
*
* MODIFICATION LOG:
* DEVELOPER                               DATE                              DESCRIPTION
* -------------------------------------------------------------------------------------------------
* Ankit Singh                          16-September-2021               Created First Version
***************************************************************************************************/
@isTest
global class SEP_MockResponseIDProofPost implements HttpCalloutMock{
    String sRequest;
    global SEP_MockResponseIDProofPost(String sRequest){
        this.sRequest = sRequest;
    }
        global HTTPResponse respond(HTTPRequest req) {
                if(sRequest == 'Failure'){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"Status":{"ConversationId":"31018939","RequestId":"114269","TransactionStatus":"pending","ActionType":"answers","Reference":"RESTv3_Example","LexID":"209297"},"Products":[{"ProductType":"Velocity","ExecutedStepName":"pre_id_velocity","ProductConfigurationName":"customers.stateofct2_gaming_velocity_preid","ProductStatus":"pass","Items":[{"ItemName":"FUTILITY","ItemStatus":"pass"}]},{"ProductType":"Discovery","ExecutedStepName":"discovery","ProductConfigurationName":"customers.stateofct2_gaming_discovery","ProductStatus":"pass"},{"ProductType":"Velocity","ExecutedStepName":"post_id_velocity","ProductConfigurationName":"customers.stateofct2_gaming_velocity_postid","ProductStatus":"pass","Items":[{"ItemName":"FREQUENCY","ItemStatus":"pass"},{"ItemName":"QUIZ","ItemStatus":"pass"}]},{"ProductType":"IdentityEvent","ExecutedStepName":"identity_events","ProductConfigurationName":"customers.stateofct2_gaming_identity_events","ProductStatus":"pass"},{"ProductType":"IIDQA","ExecutedStepName":"authentication","ProductConfigurationName":"customers.stateofct2_gaming_authentication","ProductStatus":"pending","QuestionSet":{"QuestionSetId":23109,"Questions":[{"QuestionId":30699,"Key":551,"Type":"singlechoice","Text":{"Statement":"In wyou attended college?"},"HelpText":{"Statement":"Select theve attended."},"Choices":[{"ChoiceId":5419,"Text":{"Statement":"Keer"}},{"ChoiceId":590429,"Text":{"Statement":"Nacoke"}},{"ChoiceId":590439,"Text":{"Statement":"Pinuff"}},{"ChoiceId":59049,"Text":{"Statement":"Porand"}},{"ChoiceId":59059,"Text":{"Statement":"None of the above"}}]},{"QuestionId":3001709,"Key":3001,"Type":"singlechoice","Text":{"Statement":"Which ofr leased?"},"HelpText":{"Statement":"May include you co-signed"},"Choices":[{"ChoiceId":5909469,"Text":{"Statement":"200oad"}},{"ChoiceId":590959,"Text":{"Statement":"205"}},{"ChoiceId":5489,"Text":{"Statement":"20035"}},{"ChoiceId":5900499,"Text":{"Statement":"200 Xf"}},{"ChoiceId":590509,"Text":{"Statement":"I have neicles"}}]},{"QuestionId":300719,"Key":111,"Type":"singlechoice","Text":{"Statement":"Which of d with?"},"HelpText":{"Statement":"The adiations from your actual address"},"Choices":[{"ChoiceId":59019,"Text":{"Statement":"100treet"}},{"ChoiceId":59029,"Text":{"Statement":"204et"}},{"ChoiceId":590939,"Text":{"Statement":"6221 Arive"}},{"ChoiceId":59099,"Text":{"Statement":"815n Lane"}},{"ChoiceId":590959,"Text":{"Statement":"I hathese addresses"}}]}]}}]}');
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