/*********************************************************************************************
 * NAME:  melissaAddressUtil
 * DESCRIPTION: This component is used to get address using Melissa API
 *
 * @AUTHOR: Pooja Dubey
 * @DATE: 18/01/2021
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * ----------------------------------------------------------------------------
 * Pooja Dubey                      18/01/2021                         Created the first version
*********************************************************************************************/

import { LightningElement } from 'lwc';
import getSuggestions from "@salesforce/apex/AddressValidationService.getAddressSuggestions";

const getAddressSuggestions = (requestString, statefilter, country)  => {
    return new Promise((resolve, reject) => {
    var dataSuggestions = [];
    var filterwith;
    if(statefilter != undefined){
        filterwith = 'state';
    }
    getSuggestions({
        requestString: requestString,
        country: country,
        filterwith: filterwith,
        filterlist: statefilter
    }).then(result => {
        let dataSuggestionJSON = result;
        dataSuggestions = JSON.parse(dataSuggestionJSON);
        return dataSuggestions;
        /**if (dataSuggestions) {
            this._items = dataSuggestions.map(d => {
                //let displayLabel = this.buildAddress(d);
                return {
                    label: d.text,
                    value: d.text,
                    state: d.state,
                    street_line: d.street_line,
                    city: d.city,
                    zipcode: d.zipcode,
                    secondary: d.secondary
                }
            });
        }**/
    }).then((data) => {
        resolve(data);
      })
      .catch((err) => reject(err));
  });
}

export {
    //getSuggestions,
    getAddressSuggestions
}