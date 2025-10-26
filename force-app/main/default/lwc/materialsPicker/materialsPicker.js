import { LightningElement, track } from 'lwc';

export default class MaterialsPicker extends LightningElement {
    @track name = '';
    @track quantity = 0;
    @track cost = 0;

    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleCostChange(event) {
        this.cost = event.target.value;
    }

    handleAdd() {
        this.dispatchEvent(new CustomEvent('addmaterial', {
            detail: {
                name: this.name,
                quantity: this.quantity,
                cost: this.cost
            }
        }));

        this.name = '';
        this.quantity = 0;
        this.cost = 0;
    }
}