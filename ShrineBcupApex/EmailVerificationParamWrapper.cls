/*********************************************************************************************
 * NAME:  EmailVerificationParamWrapper
 * DESCRIPTION: Wrapper class for verification paramater links. 
 *
 * @AUTHOR: Devesh Murdiya
 * @DATE: 07/22/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Devesh Murdiya                    07/22/2020                         Created the first version
 *
*************************************************************************************************/
public without sharing class EmailVerificationParamWrapper {
    public string recordId;
    public string emailAddress;
    public Date expirationDate;
    /********************************************************************************************
        METHOD NAME    : EmailLinkWrapper
        DESCRIPTION    : Constructor
        RETURN TYPE    : 
        PARAMETER      : 
    ********************************************************************************************/
    public EmailVerificationParamWrapper(String recordId, string emailAddress, Date expirationDate) {
        this.recordId = recordId;
        this.emailAddress = emailAddress;
        this.expirationDate = expirationDate;
    }
}