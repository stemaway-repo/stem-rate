import Controller from "@ember/controller"
import ModalFunctionality from "discourse/mixins/modal-functionality"

export default Controller.extend(ModalFunctionality, {
  actions: {
    cancel() {
      this.send("closeModal")
    },
    submit(form) {
      console.log(form)
    }
  }
})
