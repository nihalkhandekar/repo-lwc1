import { LightningElement, track, api } from 'lwc';

export default class CertificatePage extends LightningElement {
 @api language;
 @track apostilleNumber = '';
 @track issueDate = '';
 @track showApostille = false;

 get labels() {
    return {
        apostille: this.language === 'es' ? 'APOSTILLA' : 'APOSTILLE',
        convention: this.language === 'es' ? '(Convención de La Haya del 5 de octubre de 1961)' : '(Convention de La Haye du 5 octobre 1961)',
        country: this.language === 'es' ? 'País: Los Estados Unidos de América' : 'Country: The United States of America',
        publicDocument: this.language === 'es' ? 'ESTE DOCUMENTO PÚBLICO' : 'THIS PUBLIC DOCUMENT',
        signedBy: this.language === 'es' ? 'ha sido firmado por FRANCIS X. DOIRON' : 'has been signed by FRANCIS X. DOIRON',
        actingCapacity: this.language === 'es' ? 'en calidad de TOWN CLERK' : 'acting in the capacity of TOWN CLERK',
        term: this.language === 'es' ? 'en el Estado de Connecticut para el término del 01 de enero de 1990 al 03 de enero de 1994' : 'in the State of Connecticut for the term of January 01, 1990 to January 03, 1994',
        certified: this.language === 'es' ? 'CERTIFICADO' : 'CERTIFIED',
        atLocation: this.language === 'es' ? 'en Hartford, Connecticut' : 'at Hartford, Connecticut',
        byAuthority: this.language === 'es' ? 'por STEPHANIE THOMAS, Secretaria de Estado de Connecticut' : 'by STEPHANIE THOMAS, Secretary of the State of Connecticut',
        number: this.language === 'es' ? 'Número: 2024-10127' : 'Number: 2024-10127',
        seal: this.language === 'es' ? 'Sello:' : 'Seal:',
        signature: this.language === 'es' ? 'Firma' : 'Signature',
        secretaryOfState: this.language === 'es' ? 'Secretaria de Estado' : 'Secretary of the State'
    };
}

connectedCallback() {
    // Set language when component is connected
    this.setLanguage(this.language);
}

@api
setLanguage(language) {
    this.language = language;
    // This will automatically update the labels based on the current language
    this.requestRender(); // Triggers re-rendering with the updated labels
}

get t() {
    return this.labels;
}

// Trigger re-rendering by using this method to ensure changes are applied
requestRender() {
    this.template.querySelectorAll('.apostille-container').forEach(el => {
        el.classList.add('re-render');
    });
}
}