import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitWorkOrder from '@salesforce/apex/WorkOrderIntakeController.submitWorkOrder';

export default class WorkOrderIntake extends LightningElement {
    @track name = '';
    @track phone = '';
    @track email = '';
    @track address = '';   
    @track description = '';
    @track preferredTime = '';
    @track estimatedCost = ''; 
    @track fileIds = [];

    get timeOptions() {
        return [
            { label: 'Morning', value: 'Morning' },
            { label: 'Afternoon', value: 'Afternoon' },
            { label: 'Evening', value: 'Evening' }
        ];
    }

    handleChange(event) {
        const field = event.target.name || event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.fileIds = uploadedFiles.map(f => f.documentId);
    }

    resetForm() {
        this.name = '';
        this.phone = '';
        this.email = '';
        this.address = '';
        this.description = '';
        this.preferredTime = '';
        this.estimatedCost = '';
        this.fileIds = [];
    }

    async handleSubmit() {
        const cost = this.estimatedCost ? parseFloat(this.estimatedCost) : 0.0;
        console.log('Payload enviado ao Apex:', {
            name: this.name,
            phone: this.phone,
            email: this.email,
            address: this.address,
            description: this.description,
            preferredTime: this.preferredTime,
            estimatedCost: cost,
            fileIds: this.fileIds
        });

        try {
            await submitWorkOrder({
                name: this.name,
                phone: this.phone,
                email: this.email,
                address: this.address,
                description: this.description,
                preferredTime: this.preferredTime,
                estimatedCost: cost,
                fileIds: this.fileIds
            });

            this.resetForm();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso!',
                    message: 'Your service order was created successfully.',
                    variant: 'success'
                })
            );

            console.log('Work order successfully submitted');

        } catch (error) {
            console.error('Error submitting work order: ', error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sending error',
                    message: error.body ? error.body.message : 'An error occurred while submitting the work order.',
                    variant: 'error'
                })
            );
        }
    }
}
