import { LightningElement, track } from 'lwc';
//import governmentlogo from '@salesforce/resourceUrl/GovernmentLogo';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';


export default class EApostilleFormExperienceSite extends LightningElement {
    @track currentStep = 1;
    @track language = 'en';
    @track showStaticContent = true;
    @track showFormContent = false;
    @track showVerificationContent = false;
  //  logo = governmentlogo;
    @track formData = {
        // Initialize formData fields here
        date: '',
        lastName: '',
        firstName: '',
        gender: '',
        phoneNumber: '',
        email: '',
        companyName: '',
        numberOfAuthentication: '',
        reasonApplyingFor: '',
        uploadDocumentApplyingFor: null,
        uploadDocumentApplyingForUrl: '',
        reasonAuthenticationFor: '',
        driversLicense: null,
        driversLicenseUrl: '',
        signature: null,
        signatureUrl: '',
        adoptionDocuments: false,
        expeditedService: false
    };

    steps_flow = {
        en: [
            { id: 1, label: 'General_Information' },
            { id: 2, label: 'Address' },
            { id: 3, label: 'Upload_Document' },
            { id: 4, label: 'Payment' },
        ],
        es: [
            { id: 1, label: 'Spanish_General_Information' },
            { id: 2, label: 'spanish_of_Address' },
            { id: 3, label: 'spanish_of_Upload_Document' },
            { id: 4, label: 'Spanish_of_Payment' },
        ]
    };

    translations = {
        en: {
            title: "Secretary of the State",
            orderForm: "Authentication/Apostille Order Form",
            verification: "Authentication/Apostille Verification",
            spanish: "Spanish",
            personalInformation: "Personal Information",
            address: "Address",
            payment: "Payment",
            upload_Document : "Upload Documents",
            progressDescription: "Forms will be processed within 24 hours upon receival from the Management Support Services department.",
            title_header: 'OFFICE OF THE SECRETARY OF THE STATE',
            subtitle: 'AUTHENTICATION / APOSTILLE ORDER FORM',
            website: 'Website',
            telephone: 'Telephone',
            mailingAddressTitle: 'Mailing Address:',
            mailingAddressLine1: 'Connecticut Secretary of the State, Attn: Authentications',
            mailingAddressLine2: 'P.O. Box 150470, Hartford, CT 06115-0470',
            deliveryTitle: 'Delivery by Fedex, UPS, DHL',
            deliveryLine1: 'Connecticut Secretary of the State, Attn: Authentications',
            deliveryLine2: '165 Capitol Avenue, Suite 1000, Hartford, CT 06106',
            checksPayableTo: 'Checks payable to: Secretary of the State',
            feesTitle: 'FEES/PAGO:',
            childAdoption: 'Child Adoption',
            regularDocuments: 'Regular Documents',
            expeditedService: 'Expedited/Service',
            expeditedServiceTitle: 'EXPEDITED SERVICE:',
            ordersProcessed: 'Orders will be processed and mailed within 24 hours upon receival from the Management Support Services department.',
            adoptionDocuments: 'Adoption documents cannot be expedited. Rejected documents will result in the forfeiture of expedited fee.',
            noExpeditedService: '**EXPEDITED SERVICE IS NOT AVAILABLE WHILE YOU WAIT.**',
            perDocument: 'per document'
        },
        es: {
            title: "Secretario del Estado",
            orderForm: "Formulario de Pedido de Autenticación/Apostilla",
            verification: "Verificación de Autenticación/Apostilla",
            spanish: "Español",
            personalInformation: "Información Personal",
            address: "Dirección",
            payment: "Pago",
            upload_Document: "subir documentos",
            progressDescription: "Los formularios se procesarán dentro de las 24 horas posteriores a la recepción del departamento de Servicios de Apoyo a la Gestión.",
            title_header: 'OFICINA DEL SECRETARIO DEL ESTADO',
            subtitle: 'FORMULARIO DE PEDIDO DE AUTENTICACIÓN / APOSTILLA',
            website: 'Sitio web',
            telephone: 'Teléfono',
            mailingAddressTitle: 'Dirección postal:',
            mailingAddressLine1: 'Secretario del Estado de Connecticut, Atención: Autenticaciones',
            mailingAddressLine2: 'P.O. Box 150470, Hartford, CT 06115-0470',
            deliveryTitle: 'Entrega por Fedex, UPS, DHL',
            deliveryLine1: 'Secretario del Estado de Connecticut, Atención: Autenticaciones',
            deliveryLine2: '165 Capitol Avenue, Suite 1000, Hartford, CT 06106',
            checksPayableTo: 'Cheques a nombre de: Secretario del Estado',
            feesTitle: 'TARIFAS/PAGO:',
            childAdoption: 'Adopción de Niños',
            regularDocuments: 'Documentos Regulares',
            expeditedService: 'Servicio Expedito',
            expeditedServiceTitle: 'SERVICIO EXPEDITO:',
            ordersProcessed: 'Los pedidos serán procesados y enviados por correo dentro de las 24 horas posteriores a la recepción del departamento de Servicios de Apoyo a la Gestión.',
            adoptionDocuments: 'Los documentos de adopción no se pueden acelerar. Los documentos rechazados resultarán en la pérdida de la tarifa acelerada.',
            noExpeditedService: '**EL SERVICIO EXPEDITO NO ESTÁ DISPONIBLE MIENTRAS ESPERA.**',
            perDocument: 'por documento'
        }
    };

    @track steps = [
        { id: 1, label: 'Personal Information', isCompleted: true, isApproved: true },
        { id: 2, label: 'Address', isCompleted: true, isApproved: false },
        { id: 3, label: 'Payment', isCompleted: false, isApproved: false },
        { id: 4, label: 'Review', isCompleted: false, isApproved: false },
    ];

    get isStepOne() {
        return this.currentStep === 1;
    }

    get isStepTwo() {
        return this.currentStep === 2;
    }

    get isStepThree() {
        return this.currentStep === 3;
    }

    get isStepFour() {
        return this.currentStep === this.steps.length;
    }

  
    get step1Class() {
        return this.getStepClass(1);
    }

    get step2Class() {
        return this.getStepClass(2);
    }

    get step3Class() {
        return this.getStepClass(3);
    }

    get step4Class() {
        return this.getStepClass(4);
    }

    get step1LabelClass() {
        return this.getLabelClass(1);
    }

    get step2LabelClass() {
        return this.getLabelClass(2);
    }

    get step3LabelClass() {
        return this.getLabelClass(3);
    }

    get step4LabelClass() {
        return this.getLabelClass(4);
    }

    getStepClass(step) {
        return this.currentStep === step ? 'slds-progress__item slds-is-active' : 'slds-progress__item';
    }
    showVerificationForm() {
        this.showStaticContent = false;
        this.showFormContent = false;
        this.showVerificationContent = true;
    }

    handleAccountStatusChange(event) {
        console.log('Event Detail:', JSON.stringify(event.detail));
        const locationName = event.detail.locationName;

        if (locationName) {
            const currentStepLabel = this.getStepLabelFromLocation(locationName);
            this.updateCurrentStep(currentStepLabel);
        }
    }

    getStepLabelFromLocation(locationName) {
        const step = this.steps_flow[this.language].find(s => s.label === locationName);
        return step ? step.label : null;
    }

    updateCurrentStep(currentStepLabel) {
        const step = this.steps_flow[this.language].find(s => s.label === currentStepLabel);
        if (step) {
            const newStepId = step.id;
            if (newStepId > this.currentStep) {
                this.handleNext();
            } else if (newStepId < this.currentStep) {
                this.handlePrevious();
            }
        }
    }

    getLabelClass(step) {
        return this.currentStep === step ? 'bold-label' : '';
    }

    handleNext() {
        if (this.currentStep <  this.steps.length) {
            this.currentStep++;
        }
    }

    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep--;
        }
    }        

    handleSubmit() {
        // Handle the form submission logic here
        console.log('Form submitted');
    }


    handleFormDataChange(event) {
        this.formData = { ...this.formData, ...event.detail };
        console.log('formData..........',this.formData)
    }

    showFormSection() {
        this.showStaticContent = false;
        this.showFormContent = true;
    }

    handleLanguageToggle(event) {
        this.language = event.target.checked ? 'es' : 'en';
        this.showStaticContent = true;
        this.showFormContent = false;
        this.showVerificationContent = false;
        
         // Ensure that all instances of the child component are updated
    this.template.querySelectorAll('c-apostille-certificate').forEach(child => {
        if (typeof child.setLanguage === 'function') {
            child.setLanguage(this.language);
    }
});
}


    get i18n() {
        return this.translations[this.language];
    }

    get inputVariables() {
        return [
          {
            // Match with the input variable name declared in the flow.
            name: "Language",
            type: "String",
            // Initial value to send to the flow input.
            value: this.language,
          }
        ];
      }

}