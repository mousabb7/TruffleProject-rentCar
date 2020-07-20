App = {
  web3: null,
  web3Provider: null,
  contracts: {},
 
  init: async function() {
    return await App.initWeb3();
  },
 
  initWeb3: async function() {
    /*
     * Replace me...
     */
    App.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'));
    return App.initContract();
  },
 
  initContract: function() {
    /*
     * Replace me...
     */
    console.log(App.web3)
 
    $.getJSON('../car.json', function(car) {
      console.log("car", car)
      App.contracts["car"] = new App.web3.eth.Contract(car.abi, "0x5d046dcf51d69C32962e3279e42354C57c5d0D15")
 
      App.contracts.car.methods.owner().call().then(function (res) {
        console.log(res)
      }).catch(function (err) {
 
      })
    });
 
 
 
    return App.bindEvents();
  },
 
  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },
 
  markAdopted: function(adopters, account) {
    /*
     * Replace me...
     */
  },
 
  handleAdopt: function(event) {
    event.preventDefault();
 
    var petId = parseInt($(event.target).data('id'));
 
    /*
     * Replace me...
     */
  }
 
};
 
$(function() {
  $(window).load(function() {
    App.init();
  });
});
