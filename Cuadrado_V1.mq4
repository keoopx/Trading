
#property copyright "keoopx"
#property link      "keoopx@gmail.com"
#property version   "4.00"
//____________________________________________________________________
#property description "Asesor basado en el cuadrado"
#property description "Usar en (XAUUSD-US30). no se afecta con la temporalidad"
#property description "Forex Energy"
//____________________________________________________________________
#property strict
//+------------------------------------------------------------------+
//| VARIABLES                                                        |<<
//+------------------------------------------------------------------+
sinput int MagicNumber=1987120403;//Identificador del Algoritmo
sinput double Lots =0.1;//Lotaje
sinput double StopLoss=0;//S/L Pips
input double TakeProfit=300;//T/P Pips
sinput bool A_TS=true;//Activar TrailingStop
sinput int TrailingStop=100;
sinput int G_M=200;//ganancia minima
sinput int Slippage=3;
sinput bool Mecha=true;//true=mechas false=cuerpo

MqlDateTime Hora_Inicio;
MqlDateTime Hora_Fin;
MqlDateTime Hora_Cierre;
MqlDateTime Hora_Actual;
MqlDateTime Hora_Aux;

double Maximo=0;//Precio mas alto
double Minimo=0;//Precio mas bajo
double Max_Barras[23];//vector para guardar maximos de cada barra
double Min_Barras[23];//vector para guardar minimos de cada barra

int Orden_Buy=0;//tiquete del buy stop
int Orden_Sell=0;//tiquete del sell stop

double Equidad=0;
int TotalEjecutadas=0;

int AllowedAccountNo1=0;
int AllowedAccountNo2=0;
int AllowedAccountNo3=0;
int AllowedAccountNo4=0;


//+-BANDERAS---------------------------------------------------------+
bool Orden_Seleccionada=false;
bool Orden_Modificada=false;
bool Orden_Cerrada=false;
bool Activado=false;//activacion del bot por mi
bool Inicio=false;//inicio de la hora magica
bool Fin=false;//fin de la hora magica
bool Cierre=true;//cierre del mercado, fin del dia
bool Operar=true;//para abrir las ordenes una sola vez 
bool Comenzar=true;//para tomar parametros iniciales una vez
bool Cerrar_Todo=true;//para cerrar y borrar todo una vez


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


int OnInit()
{
//validacion
string chara[256];
for (int i = 0; i < 256; i++) chara[i] = CharToStr(i);
  
AllowedAccountNo1 = StrToInteger(chara[50]+chara[49]+chara[49]+chara[51]+chara[55]+chara[56]+chara[48]+chara[56]);									
									
									
									
if (AccountNumber() == AllowedAccountNo1)									
{									
 Activado=true;									
}									
								
								

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
TimeToStruct(TimeCurrent(),Hora_Actual);
TimeToStruct(TimeCurrent(),Hora_Inicio);
TimeToStruct(TimeCurrent(),Hora_Fin);
TimeToStruct(TimeCurrent(),Hora_Cierre);

TimeToStruct(StrToTime("05:01"),Hora_Aux);
Hora_Inicio.hour=Hora_Aux.hour;
Hora_Inicio.min=Hora_Aux.min;

TimeToStruct(StrToTime("09:01"),Hora_Aux);
Hora_Fin.hour=Hora_Aux.hour;
Hora_Fin.min=Hora_Aux.min;

if(TimeDayOfWeek(TimeCurrent())==5)
{
   TimeToStruct(StrToTime("19:01"),Hora_Aux);
   Hora_Cierre.hour=Hora_Aux.hour;
   Hora_Cierre.min=Hora_Aux.min;
}
else
{
   TimeToStruct(StrToTime("23:01"),Hora_Aux);
   Hora_Cierre.hour=Hora_Aux.hour;
   Hora_Cierre.min=Hora_Aux.min;
}

//+-INICIO HORA MAGICA-----------------------------------------------+
if((Hora_Actual.hour*100+ Hora_Actual.min>=Hora_Inicio.hour*100+ Hora_Inicio.min)&&(Hora_Actual.hour*100+ Hora_Actual.min<Hora_Fin.hour*100+ Hora_Fin.min))
{
   Inicio=true;
}

if(Inicio&&Activado)
{//mientras sea la hora magica
   if(Comenzar)
   {//solo hacerlo una vez en el dia al comenzar
      Maximo=Ask;
      Minimo=Bid;
      Max_Barras[1]=Ask;
      Max_Barras[2]=Ask;
      Max_Barras[3]=Ask;
      Max_Barras[4]=Ask;
      Min_Barras[1]=Bid;
      Min_Barras[2]=Bid;
      Min_Barras[3]=Bid;
      Min_Barras[4]=Bid;
      
      ObjectCreate("Maximo", OBJ_TEXT, 0, StructToTime(Hora_Inicio), Ask);
      ObjectSet("Maximo",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectCreate("Minimo", OBJ_TEXT, 0, StructToTime(Hora_Fin), Ask);
      
      ObjectCreate("INICIO", OBJ_TEXT, 0,StructToTime(Hora_Inicio), Ask);
      ObjectSetText("INICIO","|>|", 10, "Arial Black", Blue);
      
      if(Mecha)
      {
         if(Hora_Actual.hour==5)
         {
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,0));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,0));
         }
         if(Hora_Actual.hour==6)
         {
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,0));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,0));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,1));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,1));
         }
         if(Hora_Actual.hour==7)
         {
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,0));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,0));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,1));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,1));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,2));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,2));
         }
         if(Hora_Actual.hour==8)
         {
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,0));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,0));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,1));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,1));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,2));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,2));
            Maximo=MathMax(Maximo,iHigh(Symbol(),60,3));
            Minimo=MathMin(Minimo,iLow(Symbol(),60,3));
         }
      }
      else
      {
         for(int k=0;k<=(Hora_Actual.hour-5);k++)
         {
            //if(Hora_Actual.hour==(k+5))
            //{
               Max_Barras[k+1]=MathMax(iClose(Symbol(),60,k),iOpen(Symbol(),60,k));
               Min_Barras[k+1]=MathMin(iClose(Symbol(),60,k),iOpen(Symbol(),60,k));
            //}
         }
      }
      
      Comenzar=false;//para no entrar de nuevo
      Cerrar_Todo=true;
   }
   
   if(Mecha)
   {
      Maximo=MathMax(Maximo,iHigh(Symbol(),0,0));
      Minimo=MathMin(Minimo,iLow(Symbol(),0,0));
   }
   else
   {
      for(int k=0;k<=3;k++)
      {
         if(Hora_Actual.hour==(k+5))
         {
            Max_Barras[k+1]=MathMax(iClose(Symbol(),60,0),iOpen(Symbol(),60,0));
            Min_Barras[k+1]=MathMin(iClose(Symbol(),60,0),iOpen(Symbol(),60,0));
         }
      }
      Maximo=MathMax(Max_Barras[1],Max_Barras[2]);
      Maximo=MathMax(Maximo,Max_Barras[3]);
      Maximo=MathMax(Maximo,Max_Barras[4]);
      Minimo=MathMin(Min_Barras[1],Min_Barras[2]);
      Minimo=MathMin(Minimo,Min_Barras[3]);
      Minimo=MathMin(Minimo,Min_Barras[4]);
   }
   
   ObjectSetText("Maximo",DoubleToStr(Maximo,Digits), 8, "Arial Black", Blue);
   ObjectSet("Maximo",OBJPROP_PRICE1,Maximo);
   ObjectSetText("Minimo",DoubleToStr(Minimo,Digits), 8, "Arial Black", Blue);
   ObjectSet("Minimo",OBJPROP_PRICE1,Minimo);
}
//+******************************************************************+
//+-FIN HORA MAGICA--------------------------------------------------+
if(Activado)
{
if(Hora_Actual.hour*100+ Hora_Actual.min==Hora_Fin.hour*100+ Hora_Fin.min)
{
   Fin=True;
   ObjectCreate("FIN", OBJ_TEXT, 0, StructToTime(Hora_Fin), Ask);
   ObjectSetText("FIN","|<|", 10, "Arial Black", Blue);
}

if(Fin&&Operar)//cuando se acabe la hora magica
{//colocar ordenes pendientes
   
   ObjectCreate("Cuadro_Magico", OBJ_RECTANGLE,0, StructToTime(Hora_Inicio), Maximo,StrToTime("09:00"),Minimo);
   Inicio=false;
   Orden_Buy=Abrir_Orden(OP_BUYSTOP,Lots,Maximo+(1/(MathPow(10,Digits-1))),TakeProfit,StopLoss,"KeoopX-US30",Blue);
   Orden_Sell=Abrir_Orden(OP_SELLSTOP,Lots,Minimo-(1/(MathPow(10,Digits-1))),-TakeProfit,-StopLoss,"KeoopX-US30",Red);
   
   /*ObjectCreate("Max1",OBJ_HLINE,0,0,Max_Barras[1]);
   ObjectCreate("Max2",OBJ_HLINE,0,0,Max_Barras[2]);
   ObjectCreate("Max3",OBJ_HLINE,0,0,Max_Barras[3]);
   ObjectCreate("Max4",OBJ_HLINE,0,0,Max_Barras[4]);
   
   ObjectCreate("Min1",OBJ_HLINE,0,0,Min_Barras[1]);
   ObjectCreate("Min2",OBJ_HLINE,0,0,Min_Barras[2]);
   ObjectCreate("Min3",OBJ_HLINE,0,0,Min_Barras[3]);
   ObjectCreate("Min4",OBJ_HLINE,0,0,Min_Barras[4]);*/
   
   Fin=false;//para ejecutar una sola vez
   Operar=false;//para ejecutar una sola vez
}
//+******************************************************************+
//+-CIERRE DEL MERCADO-----------------------------------------------+
if(Hora_Actual.hour*100+ Hora_Actual.min==Hora_Cierre.hour*100+ Hora_Cierre.min)
{
   Cierre=true;
   ObjectCreate("CIERRE"+TimeToStr(TimeCurrent(),TIME_DATE), OBJ_TEXT, 0,StructToTime(Hora_Cierre) , Ask);
   ObjectSetText("CIERRE"+TimeToStr(TimeCurrent(),TIME_DATE),"||", 10, "Arial Black", Blue);
}

if(Cierre)
{
   ObjectDelete("Maximo");
   ObjectDelete("Minimo");
   ObjectDelete("INICIO");
   ObjectDelete("FIN");
   ObjectDelete("Cuadro_Magico");
   /*
   ObjectDelete("Max1");
   ObjectDelete("Max2");
   ObjectDelete("Max3");
   ObjectDelete("Max4");
   ObjectDelete("Min1");
   ObjectDelete("Min2");
   ObjectDelete("Min3");
   ObjectDelete("Min4");
   */

   
   Orden_Seleccionada=OrderSelect(Orden_Buy,SELECT_BY_TICKET);
   if(OrderType()==OP_BUYSTOP) Orden_Cerrada=OrderDelete(Orden_Buy,Red);
   
   Orden_Seleccionada=OrderSelect(Orden_Sell,SELECT_BY_TICKET);
   if(OrderType()==OP_SELLSTOP) Orden_Cerrada=OrderDelete(Orden_Sell,Red);
   
   Maximo=0;
   Minimo=0;
   
   Cierre=false;
   Inicio=false;
   Fin=false;
   
   Cerrar_Todo=false;
   Operar=true;
   Comenzar=true;
}
}
//+******************************************************************+

//guardamos la mayor perdida
Equidad=MathMax(Equidad,AccountBalance()-AccountEquity());

if(A_TS) TS(G_M);

/*Comment("Dia Semana: ", IntegerToString( TimeDayOfWeek(TimeCurrent())),"\n",
        "Mayor equity: ",Equidad,"\n",
        "Margen Requerido: ",MarketInfo(Symbol(),MODE_MARGINREQUIRED)*Lots,"\n",
        "Lotaje Min: ", MarketInfo(Symbol(),MODE_MINLOT),"\n",
        "Tiempo Actual: ", IntegerToString( Hora_Actual.hour)+":"+ IntegerToString(Hora_Actual.min,2,'0'),"\n",
        "Tiempo Inicio: ",IntegerToString( Hora_Inicio.hour)+":"+ IntegerToString(Hora_Inicio.min,2,'0'),"\n",
        "Inicio: ", Inicio,"\n",
        "Fin: ", Fin,"\n",
        "Cierre: ", Cierre,"\n",
        "Operar: ", Operar,"\n",
        "Comenzar: ", Comenzar,"\n",
        "Cerrar Todo : ", Cerrar_Todo,"\n",
        "Vela 1: ",Max_Barras[1]," - ",Min_Barras[1],"\n",
        "Vela 2: ",Max_Barras[2]," - ",Min_Barras[2],"\n",
        "Vela 3: ",Max_Barras[3]," - ",Min_Barras[3],"\n",
        "Vela 4: ",Max_Barras[4]," - ",Min_Barras[4],"\n"
        );*/
Comment("Margen Requerido a ",Lots," lotes: ",MarketInfo(Symbol(),MODE_MARGINREQUIRED)*Lots,"\n",
        "Lotaje Min: ", MarketInfo(Symbol(),MODE_MINLOT),"\n",
        "Tiempo Actual: ", IntegerToString( Hora_Actual.hour)+":"+ IntegerToString(Hora_Actual.min,2,'0'),"\n",
        "Tiempo Inicio: ",IntegerToString( Hora_Inicio.hour)+":"+ IntegerToString(Hora_Inicio.min,2,'0'),"\n",
        "Activacion: ",Activado
        );

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+*FUNCIONES********************************************************+<<
//+------------------------------------------------------------------+
//| Abrir Orden                                                      |<<
//+------------------------------------------------------------------+
int Abrir_Orden(int Tipo_Orden, double Lotaje , double Precio, double TP, double SL, string Comentario, color Flecha)
{
double MyPoint=Point;//debe ser el minimo cambio que se presenta en la divisa, casi que el mismo pips
double TheStopLoss=0;
double TheTakeProfit=0;

int result=0;//guardamos el tiquete de la orden
result=OrderSend(Symbol(),Tipo_Orden,Lotaje,Precio,Slippage,0,0,Comentario,MagicNumber,0,Flecha);
if(result>0)//TIENE UN NUMERO DE TICKET
{
   TotalEjecutadas++;//contar ordenes ejecutadas en total
   if(TP!=0) TheTakeProfit=Precio+TP*MyPoint*10;
   if(SL!=0) TheStopLoss=Precio-SL*MyPoint*10;
   Orden_Seleccionada=OrderSelect(result,SELECT_BY_TICKET);
   Orden_Modificada=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TheStopLoss,Digits),NormalizeDouble(TheTakeProfit,Digits),0,Green);
   return(result);
}
else
{
   printf("Error al Abrir la orden. ",GetLastError());
   return(result);
}
}
//+******************************************************************+
//+------------------------------------------------------------------+
//| TrailingStop                                                     |<<
//+------------------------------------------------------------------+
bool TS(int Ganancia_Min)
{
double MyPoint=Point;//debe ser el minimo cambio que se presenta en la divisa, casi que el mismo pips

for(int i=0;i<OrdersTotal();i++)
   {
      Orden_Seleccionada=OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
      if(!Orden_Seleccionada) printf("Error al seleccionar orden. ",GetLastError());
      //SELECT_BY_POS - index in the order pool, 
      if (OrderMagicNumber()==MagicNumber)//cuenta las ordenes abiertas por el algoritmo comparando el numero magico
      {
         if(OrderType()==OP_BUY)
         {
            if ((Bid - OrderOpenPrice()) > Ganancia_Min*MyPoint*10)
            {
            if (OrderStopLoss() < (Bid-TrailingStop*MyPoint*10))
               {
                  Orden_Modificada=OrderModify(OrderTicket(), OrderOpenPrice(), Bid-TrailingStop*MyPoint*10, 0, Red);
                  return(true);
               }
            }
         }
         if(OrderType()==OP_SELL)
         {
            if ((OrderOpenPrice() - Ask) > Ganancia_Min*MyPoint*10)
            {
            if (OrderStopLoss() > (Ask+TrailingStop*MyPoint*10) || (OrderStopLoss() == 0))
               {
                  Orden_Modificada=OrderModify(OrderTicket(), OrderOpenPrice(), Ask+TrailingStop*MyPoint*10, 0, Red);
                  return(true);
               }
            }
         }
      }
   }
   return(true);
}