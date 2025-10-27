import { LightningElement, track, wire } from 'lwc';
import getWorkOrders from '@salesforce/apex/TechMobileController.getWorkOrders';
import finalizeJob from '@salesforce/apex/TechMobileController.finalizeJob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TechMobileApp extends LightningElement {
    @track workOrders = [];
    @track selectedOrderId = null;
    @track materials = [];
    @track serviceDesc = '';
    @track hoursWorked = 0;
    @track showForm = false;
    @track wiredWorkOrdersResult;

    @wire(getWorkOrders)
    wiredOrders(result) {
        this.wiredWorkOrdersResult = result;
        if (result.data) {
            this.workOrders = result.data;
        } else if (result.error) {
            console.error('Error loading work orders: ', result.error);
        }
    }

    handleSelectOrder(event) {
        this.selectedOrderId = event.target.dataset.id;
        this.showForm = true;
    }

    handleAddMaterial(event) {
        const material = { ...event.detail, id: Date.now() };
        this.materials = [...this.materials, material];
    }

    handleServiceDescChange(event) {
        this.serviceDesc = event.target.value;
    }

    handleHoursChange(event) {
        this.hoursWorked = parseFloat(event.target.value) || 0;
    }

    async handleFinalizeJob() {
        if (!this.selectedOrderId) {
            console.error('Work order ID está faltando');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Nenhuma ordem de serviço selecionada.',
                    variant: 'error',
                })
            );
            return;
        }

        try {
            const result = await finalizeJob({
                workOrderId: this.selectedOrderId,
                hoursWorked: this.hoursWorked
            });

            if (result.success) {
                console.log('Job finalized. ID:', result.workOrderId, 'Cost:', result.finalCost);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: `Work order ${result.workOrderId} succefully closed!`,
                        variant: 'success',
                    })
                );
                this.resetForm();
            } else {
                console.error('Error finalizing job:', result.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: result.message,
                        variant: 'error',
                    })
                );
            }
        } catch (error) {
            console.error('Unexpected error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro inesperado',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error',
                })
            );
        }
    }

    resetForm() {
        this.selectedOrderId = null;
        this.showForm = false;
        this.serviceDesc = '';
        this.hoursWorked = 0;
        this.materials = [];
    }

}