import fetchInterfaceConfig from '@salesforce/apex/brs_contactDetailPage.fetchInterfaceConfig';

var  link,authId,authToken,sitekey ;

const statusCodes = {
  200: "OK",
  400: "Bad Request",
  401: "Unauthorized",
  402: "Payment Required",
  403: "Forbidden",
  413: "Request Entity Too Large",
  422: "Unprocessable Entity",
  429: "Too Many Requests",
  504: "Gateway Timeout"
};

const isSet = (x) => x;

const siteKeyVal = [`key=${sitekey}`].filter(isSet).join("&");

const headers = {
  "Content-Type": "application/json"
};

const getAuthIdKeys = () =>{
  fetchInterfaceConfig({
  })
  .then(result => {
    var parsedResult = JSON.parse(JSON.stringify(result));
        authId = parsedResult.AuthId__c;
        authToken = parsedResult.AuthToken__c;
        sitekey = parsedResult.API_Key__c;
        link = parsedResult.End_URL__c;
  })
}

const getAddressSuggestions = (search, stateFilter) => {

  return new Promise((resolve, reject) => {

    const authIdAndToken = [
      `auth-id=${authId}`,
      `auth-token=${authToken}`,
      `prefix=${search}`,
      `state_filter=${stateFilter}`,
      `key=${sitekey}`, 
    ]
    .filter(isSet)
    .join("&");
    
    fetch(`${link}?${authIdAndToken}`, {
        method: "get",
        headers
      })
      .then((result) => {
        const {
          status
        } = result;
        if (status >= 400) {
          const error = new Error(statusCodes[status] || result.statusText);
          error.code = status;
          reject(error);
        }
        return result.json();
      })
      .then((data) => {
        resolve(data);
      })
      .catch((err) => reject(err));
  });
};

const getAddressValidation = (street, unit, city, state, zip) => {
  return new Promise((resolve, reject) => {

    const authIdAndAuthToken = [
      `key=${sitekey}`,
      `auth-id=${authId}`,
      `auth-token=${authToken}`
    ]
    .filter(isSet)
    .join("&");

    const query = [
        authIdAndAuthToken,
        `street=${encodeURIComponent(street)}`,
        unit && `secondary=${encodeURIComponent(unit)}`,
        `city=${encodeURIComponent(city)}`,
        state && `state=${encodeURIComponent(state)}`,
        zip && `zipcode=${encodeURIComponent(zip)}`
      ]
      .filter(isSet)
      .join("&");

    fetch(`https://us-street.api.smartystreets.com/street-address?${query}`, {
        method: "get",
        headers
      })
      .then((result) => {
        const {
          status
        } = result;
        if (status >= 400) {
          const error = new Error(statusCodes[status] || result.statusText);
          error.code = status;
          reject(error);
        }
        return result.json();
      })
      .then((data) => {
        resolve(data);
      })
      .catch((err) => reject(err));
  });
};


export {
  getAddressSuggestions,
  getAddressValidation,
  getAuthIdKeys
};