public with sharing class LanguageRequestWrapper {
List<String> q;
    String target;
    String format;
    String source;

    public LanguageRequestWrapper(List<String> q, String target,String format){
        this.q= q;
        this.target = target;
        this.format = format;
    }

    public LanguageRequestWrapper(List<String> q, String target) {
        this.q = q;
        this.target = target;
        this.format = 'text';
        this.source = 'en';
    }
}