public with sharing class Charset {
 /**
     * Convenience method that encodes a string into bytes in charset.
     * <p>
     * @param  input string of Unicode characters
     * @param  charset name according to http://www.iana.org/assignments/character-sets/character-sets.xhtml
     * @return binary characters in charset
     */
    public static Blob encode(final String input, final String charset) {
        final Matcher m =
            Pattern.compile('(.*?)%([0-9A-F]{2})|(.+)')
            .matcher(EncodingUtil.urlEncode(input, charset)
                     .replace('+', '%20'));
        String hex = '';

        while (m.find()) {
            hex += m.group(1) == null ? ''
                : EncodingUtil.convertToHex(Blob.valueOf(m.group(1)));
            hex += m.group(2) == null ? '' : m.group(2);
            hex += m.group(3) == null ? ''
                : EncodingUtil.convertToHex(Blob.valueOf(m.group(3)));
        }
        return EncodingUtil.convertFromHex(hex);
    }

    // @isTest
    public static void test_encode() {
        System.assertEquals('2b3a418f8e99',
                            EncodingUtil.convertToHex(Charset.encode('+:AÅÄÖ',
                                                                     'cp437')));
    }

    /**
     * Convenience method that decodes bytes in charset into a string of Unicode
     * characters.
     * <p>
     * @param  input binary characters in charset
     * @param  charset name according to http://www.iana.org/assignments/character-sets/character-sets.xhtml
     * @return string of Unicode characters
     */
    public static String decode(final Blob input, final String charset){
        final String hex = EncodingUtil.convertToHex(input);
        final Integer size = hex.length() >> 1;
        final List<String> bytes = new String[size];

        for (Integer i = 0; i < size; ++i) {
            bytes.set(i, hex.mid(i << 1, 2));
        }
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), charset);
    }

    // @isTest
    public static void test_decode() {
        System.assertEquals('+:AÅÄÖ',
                            Charset.decode(EncodingUtil.convertFromHex('2b3a418f8e99'),
                                           'cp437'));
    }
}