// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//https://www.youtube.com/watch?v=iYUjuD17jG4 ---- https://www.aviacionline.com/2022/04/air-europa-y-travelx-presentan-el-primer-vuelo-nft-del-mundo/


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
contract KeyKards is ERC721URIStorage {

    modifier ownerOnly(){ require(msg.sender == KeyKardDev, "You can't do this"); _;  }
    address payable KeyKardDev;
    uint8 devDivisor = 6;



    modifier designerOnly(){ require(IsDesigner(), "You can't do this"); _; }
    address payable[8] Designers; function w3GetDesigner(uint8 artBy) public view returns(address, string memory){ return(Designers[artBy], dNames[artBy]); }
    string[8] dNames; 
    uint8 designerDivisor = 16; 
    function SetDesignerDiv(uint8 newDiv) public managerOnly(){designerDivisor = newDiv;}
    function AddDesigner(address payable newDesigner, string memory dname) public managerOnly(){
        Designers[designersCont] = newDesigner;
        dNames[designersCont] = dname;
        mintTimes.push(0);
        URIs.push("");
        ++designersCont; }
    function UpdateDesigner(uint i, address newDesigner) public managerOnly() {Designers[i] = payable(newDesigner);}
    function IsDesigner() public view returns(bool isDesigner) {
          for(uint i = 0; i < Designers.length; i++){
              if(Designers[i] == msg.sender) return true; } 
               return false; 
               }


    modifier managerOnly(){require(msg.sender ==  Manager, "Are you the manager?"); _;}
    address payable Manager;
    uint8 managerDivisor = 10; 
    function SetManagerDiv(uint8 newDiv) public managerOnly(){managerDivisor = newDiv;}
    function SetManager(address newManager) public payable managerOnly(){Manager = payable(newManager);}
    
    address payable Storage; 
    function SetMainStorage(address newStorage) public payable managerOnly(){Storage = payable(newStorage);}






    
    constructor(address _storage, string memory defaultUri, uint8 _managerDivisor, uint8 _devDivisor) payable ERC721("KeyKard", "[KYD]"){
        KeyKardDev = payable(0xDc1039ED3af2215F6fdA0cae16520c8FEfa0e5B9);
            Storage = payable(_storage);//Save storage mover dinero a Manager para pagar
                Manager = payable(msg.sender);//Esta address se usa para pagar
    
        if(msg.value >= 300000000000) {  
            KeyKardDev.transfer(msg.value);
            managerDivisor = _managerDivisor;
            devDivisor = _devDivisor;  }
        
        mintTimes.push(0);
        URIs.push(defaultUri);
     }

 

/* --- DISEÑO ---  */
    uint8 designersCont = 0;
    uint16[] mintTimes;
    string[] URIs;

    //---Manager 
    function UpdateFixUri(uint32 uriID, string calldata newUri) public managerOnly() {URIs[uriID] = newUri;}//Las KeyKards Minteadas no cambian imagen
    function DesignerIDByAddress(address dAddress) public view returns(uint8 ID){for(uint8 i = 0; i < Designers.length; i++){ if(Designers[i] == dAddress) return i; }  }

    function NewDesignURI(uint16 cloneTimes_,  string memory URIs_) designerOnly() public returns(uint uriID) {
    uriID = DesignerIDByAddress(msg.sender);
    mintTimes[uriID] = cloneTimes_;
    URIs[uriID] = (URIs_);
    return(uriID); }


   
    function GetDesign() internal returns(uint8 dID){
        for(uint8 urID = 1; urID < URIs.length; urID++){
           if(mintTimes[urID] > 0){
            KKards[mintedKKards].artBy = dID;
            --mintTimes[urID];//Resta 1 Mint al Specific URI
         
            return (urID); } 
        }

        KKards[mintedKKards].artBy = 0;
        mintTimes[0] += 1;//Suma 1 Mint al Default URI
        return (0);
    }


/* --- DISEÑO --- */




/* --- KeyKard Base --- */
    modifier isKardOwner(uint32 KKID) { require(msg.sender == ownerOf(KKID), "You are not the owner of this KeyKard"); _; }
    uint32 mintedKKards = 0;
    mapping(uint32 => KeyKard) KKards;
    struct KeyKard{
        uint8 artBy;
        uint256 ETHKK;//In WEI
        string Object;
        uint8 TorneoID;
        string OwnerXID;
    }

   
    function SetKeyKardDesign(uint32 KKID) internal returns(uint8 dID){
    dID = GetDesign();//Recupera un diseño de la lista, si no quedan se establece el 0
    _setTokenURI(KKID, URIs[dID]);
    return dID; 
    }
    function SendKeyKard(uint32 KKID, address receiver) public{
    require(ownerOf(KKID) == msg.sender, "You are not the owner of this Token");
      safeTransferFrom(msg.sender, receiver, KKID); 
      }
    function MintKeyKard(address toAddress, string memory object, string calldata _steamID) public payable  {
        _mint(toAddress, mintedKKards);

        KKards[mintedKKards].artBy = SetKeyKardDesign(mintedKKards);
        KKards[mintedKKards].ETHKK = PayKeyKard(mintedKKards, false);
        KKards[mintedKKards].Object = object;
        KKards[mintedKKards].TorneoID = 0;
        KKards[mintedKKards].OwnerXID = _steamID;

        ++mintedKKards;
    }


    function PayKeyKard(uint32 KKID, bool noPayBro) public payable returns(uint256 storageValue){

    storageValue = msg.value;

    uint256 DevAmount = uint(storageValue / devDivisor);// 16.6%
    uint256 DesignerAmount = uint(storageValue / designerDivisor);//6.6%
    uint256 ManagerAmount = uint(storageValue / managerDivisor);

    if(!noPayBro)storageValue -= DevAmount; //Porcentaje del pago por KeyKard para DonkeyMake
    if(!noPayBro)storageValue -= DesignerAmount;//Porcentaje del pago por KeyKard para los diseñadores(Mismo diseño repetido x veces)
    if(!noPayBro)storageValue -= ManagerAmount;//El porcentaje de quien administra el "Torneo"(deployea el contrato(Dueño))
    
    if(!noPayBro)KeyKardDev.transfer(DevAmount);
    if(!noPayBro)Designers[KKards[KKID].artBy].transfer(DesignerAmount);
    if(!noPayBro)Manager.transfer(ManagerAmount);  
    
    Storage.transfer(storageValue);//Aqui se almacenan los dineros de todos los concursantes, responsabilidad del Manager.
    return(storageValue);
    }

/* --- KeyKard Base --- */






/* --- KeyKard Web3 --- */
 function w3ViewKeyKard(uint32 KKID) public view returns(uint8 artBy, uint256 ETHKK, string memory Object, uint8 TorneoID, string memory OwnerXID){
         artBy = KKards[KKID].artBy;
         ETHKK = KKards[KKID].ETHKK;
         Object = KKards[KKID].Object;
         TorneoID = KKards[KKID].TorneoID;
         OwnerXID = KKards[KKID].OwnerXID; }





uint16 eContID = 0;
function EventIDReset() public {eContID = 0;}
function EventKKINDEX(uint8 eID, uint32 KKID) public view returns(uint32){
        for(uint16 x = 0; x<Eventos[eID].joinedKards.length; ++x){
        if(Eventos[eID].joinedKards[x] == KKID) return x;//Si el torneo es privado
        }
        return 0;}


function IsEventManager(uint8 eID, uint32 KKID) isKardOwner(KKID) public view returns(bool){
uint32 index = EventKKINDEX(eID, KKID);
return Eventos[eID].eManager[index]; }

function w3SetEventManager(uint8 eID, uint32 KKID) public managerOnly(){
uint32 index = EventKKINDEX(eID, KKID);
Eventos[eID].eManager[index] = true; }



function w3EManagerInvite(uint32 myKK, uint8 eID, uint32 KKID) public {
    require(IsEventManager(eID, myKK), "You can't send invites with this KeyKard");
    Eventos[eID].joinedKards.push(KKID);//Invitacion mediante KeyKard
    Eventos[eID].eManager.push(false);}

function w3ForceJoin(uint32 KKID, uint8 eID, bool eManager) managerOnly() public{ 
 KKards[KKID].TorneoID = eID;
 Eventos[eID].slots -= 1;
 Eventos[eID].joinedKards.push(KKID);
 Eventos[eID].eManager.push(eManager); }

mapping (uint16 => Evento) Eventos;
struct Evento{
    bool isPublic;
    uint256 toJoinETH;
    uint16 slots;

    bool[] eManager;//Establece si el KeyKard puede invitar otras KeyKards
    uint32[] joinedKards;//KeyKard con acceso
}
function w3SetUpEvent(uint256 _toJoinETH, uint16 _slots, bool _isPublic) public managerOnly() returns(uint16){
    eContID += 1;
    Eventos[eContID].isPublic = _isPublic;
    Eventos[eContID].toJoinETH = _toJoinETH;
    Eventos[eContID].slots = _slots;

    Eventos[eContID].eManager.push(false);
    Eventos[eContID].joinedKards.push(0);
    return(eContID);
}


function CanJoin(uint8 eID, uint32 KKID) public view returns(bool){
require(Eventos[eID].slots >= 1, "No slots Left");
require(KKards[KKID].ETHKK >= Eventos[eID].toJoinETH, "Not enough ETH in your KeyKard");

uint32 KKIndex = EventKKINDEX(eID, KKID);
require(Eventos[eID].joinedKards[KKIndex] == KKID || Eventos[eID].isPublic, "You can't join this tournament");


 return true;//Si es publico
}


    /*Estableces la ID del Torneo para tu KeyKard*/
    function w3JoinKeyKard(uint8 eID, uint32 KKID) isKardOwner(KKID) public{ 
        require(KKards[KKID].TorneoID == 0, "This KeyKard still in another Event.");
        require(CanJoin(KKID, eID), "You can't join this Event.");
        KKards[KKID].TorneoID = eID;
        Eventos[eID].slots -= 1;
        }







    /*Check user id in torneo*/
  function w3XIDInTorneo(uint32 KKID, uint8 eID) public view returns(string memory OwnerXID){
      require(KKards[KKID].TorneoID != 0, "This player is not in a Tournament");
      require(KKards[KKID].TorneoID == eID, "This player is in another tournament");

      return(KKards[KKID].OwnerXID); 
      }


    function w3SetObject(uint32 KKID, string memory object) public managerOnly(){
        KKards[KKID].Object = object; }//Default = ""
      function w3GetObject(uint32 KKID) public view managerOnly() returns(string memory) {
        return KKards[KKID].Object; }
     /*Called by manager to set new datas*/
    function w3ExitEventSet(uint32 myKK, uint8 torneoID, uint32[] memory winedTo, string memory object) public managerOnly(){//Set winner balances and exit
    w3XIDInTorneo(myKK, torneoID);//Si no pertenece a este torneo falla
    w3SetObject(myKK, object);
        for(uint x = 0; x < winedTo.length; ++x){
            w3XIDInTorneo(winedTo[x], torneoID);//Si no pertenece a este torneo falla

            KKards[myKK].ETHKK += KKards[winedTo[x]].ETHKK;//Ganador Eth += Perdedor Eth

            KKards[winedTo[x]].ETHKK = 0;//Perdedor ETH = 0
            KKards[winedTo[x]].TorneoID = 0;

        }   KKards[myKK].TorneoID = 0; }





    /* Called by user when want to exit ETH*/
    function w3PayRequest(uint32 KKID) public isKardOwner(KKID) {//Cuando se paga ETHKK = 0
    require(KKards[KKID].TorneoID == 0, "Your KeyKard is in a Tournament");
    SendKeyKard(KKID, Storage); }


    function adminPaydBurn(uint32 KKID) public managerOnly(){ _burn(KKID); }
    function w3ManagerPay(uint32 KKID, bool burn) public payable {//Pay Winner Kard
    require(KKards[KKID].ETHKK <= msg.value, "The receiver must get the whole Amount To Pay");
    payable(ownerOf(KKID)).transfer(KKards[KKID].ETHKK);
    payable(msg.sender).transfer((msg.value - KKards[KKID].ETHKK));
    KKards[KKID].ETHKK = 0;
    if(burn)adminPaydBurn(KKID); 
    }
}
