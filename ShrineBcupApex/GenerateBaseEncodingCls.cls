/*********************************************************************************************
 * NAME:  GenerateBaseEncodingcls
 * DESCRIPTION: Convert the String to Base 64 encoding and decoding. 
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
public without sharing class GenerateBaseEncodingCls {
    private static String UTF_8_ENCODE = 'UTF-8';
    /********************************************************************************************
        METHOD NAME    : generateDecodeString
        DESCRIPTION    : Decode the blob text URL to String on Base64.
        RETURN TYPE    : String
        PARAMETER      : String
    ********************************************************************************************/
    public static String generateDecodeString(String encodedCipherText) {
        return EncodingUtil.base64Decode(EncodingUtil.urlDecode(encodedCipherText, UTF_8_ENCODE)).toString();
    }
    /********************************************************************************************
        METHOD NAME    : generateEncodeString
        DESCRIPTION    : Encode the text to Base64 encoding.
        RETURN TYPE    : String
        PARAMETER      : String
    ********************************************************************************************/
    public static String generateEncodeString(String parameter) {
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(blob.valueOf(parameter)), UTF_8_ENCODE);
    }
    /********************************************************************************************
        METHOD NAME    : encodeURL
        DESCRIPTION    : Process the paramaeter for encoding
        RETURN TYPE    : String
        PARAMETER      : String, String, Date
    ********************************************************************************************/
    public static String encodeURL(String recordId, String emailAddress, Date expirationDate) {
        EmailVerificationParamWrapper paramWrapper = new EmailVerificationParamWrapper(recordId, emailAddress, expirationDate);
        return generateEncodeString(JSON.serialize(paramWrapper));
    }
    /********************************************************************************************
        METHOD NAME    : decodeURL
        DESCRIPTION    : Process the paramaeter for encoding
        RETURN TYPE    : String
        PARAMETER      : String
    ********************************************************************************************/
    public static EmailVerificationParamWrapper decodeURL(String encodedCipherText) {
        return (EmailVerificationParamWrapper)Json.deserialize(generateDecodeString(encodedCipherText), EmailVerificationParamWrapper.class);
    }
}