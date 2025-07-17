global class SendGridResponseMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      if (req.getEndpoint().endsWith('send')) {
        //HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"success", "code":"250"}');
        res.setStatusCode(200);
        
      } else if (req.getEndpoint().endsWith('email')) {
        
          res.setHeader('Content-Type', 'application/json');
          res.setBody('{"result":{"email":"test@test.com","verdict":"Valid"}}');
          res.setStatusCode(200);
          //return res;
      }
      return res;
    }
  }