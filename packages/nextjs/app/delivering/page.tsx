"use client";

import React, { useEffect, useRef, useState } from "react";
import { GoogleMap, Libraries, Marker, useLoadScript } from "@react-google-maps/api";
import { EyeOffIcon, XIcon } from "lucide-react";
import type { NextPage } from "next";
import { useDispatch, useSelector } from "react-redux";
import { useAccount } from "wagmi";
import { Header } from "~~/components/Header";
import { Address } from "~~/components/scaffold-eth";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth/useScaffoldWriteContract";
import { setOrderAccepted } from "~~/store/slices/orderSlice";
import { setAvailability } from "~~/store/slices/riderSlice";
// Importa la acción para aceptar la orden
import { RootState } from "~~/store/store";

const libraries: Libraries = ["places"];

const Delivering: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const mapRef = useRef<google.maps.Map | null>(null);

  const dispatch = useDispatch();
  const rider = useSelector((state: RootState) => state.rider); // Estado del repartidor
  const orderFromState = useSelector((state: RootState) => state.order.order); // Estado de la orden

  const [orderAccepted, setOrderAcceptedState] = useState(orderFromState?.isAccepted || false); // Estado de aceptación de la orden
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("DispatchEcho");

  const takeOrder = async () => {
    try {
      await writeYourContractAsync({
        functionName: "takeOrder",
        args: [BigInt(3)],
      });
    } catch (e) {
      console.error("Error setting greeting:", e);
    }
    setOrderAcceptedState(true); // Marca la orden como aceptada en el estado local
    dispatch(setOrderAccepted(true)); // Marca la orden como aceptada en el estado global
  };

  const mapContainerStyle: React.CSSProperties = {
    width: "100vw",
    height: "100vh",
    position: "absolute" as const,
    top: 0,
    left: 0,
    zIndex: -1,
  };

  const center = {
    lat: -3.745,
    lng: -38.523,
  };

  const options = {
    disableDefaultUI: true,
    mapTypeControl: false,
    streetViewControl: false,
    zoomControl: false,
    fullscreenControl: false,
  };

  const { isLoaded } = useLoadScript({
    googleMapsApiKey: "AIzaSyBBj2OwjYHibtANUHRFmuM-n7307E2Nauo",
    libraries,
  });

  const onLoad = (map: google.maps.Map) => {
    mapRef.current = map;
  };

  useEffect(() => {
    if (mapRef.current) {
      mapRef.current.setOptions(options);
    }
  }, [isLoaded]);

  // Maneja el click del botón GO
  const handleGoClick = () => {
    dispatch(setAvailability(!rider.isAvailable)); // Cambia la disponibilidad del repartidor
  };

  // Maneja el click del botón Cerrar
  const handleCloseClick = () => {
    dispatch(setAvailability(false)); // Cambia la disponibilidad del repartidor a false
  };

  // Maneja la aceptación de la orden
  const handleOrderAcceptance = () => {
    setOrderAcceptedState(true); // Marca la orden como aceptada en el estado local
    dispatch(setOrderAccepted(true)); // Marca la orden como aceptada en el estado global
  };

  const isOrderAvailable = orderFromState && !orderFromState.isAccepted;

  return (
    <div className="relative w-full h-full min-h-screen">
      {isLoaded && (
        <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={15} onLoad={onLoad}>
          <Marker position={center} />
        </GoogleMap>
      )}
      <div className="relative z-10 m-[20px] flex flex-col justify-between h-[calc(100vh-100px)]">
        <div className="relative gap-[50px] flex flex-col ">
          <Header />
          <div
            className={`text-[#000000] w-full bg-[#FFFFFF] p-[16px] h-[74px] rounded-[12px] border border-solid border-[#E5E7EB] flex justify-between items-center`}
          >
            <div className="flex flex-col gap-[5px]">
              <h1 className="text-[16px] m-0 font-bold ">Gilberts</h1>
              <Address address={connectedAddress} />
            </div>
            <div
              className={`flex items-center ${
                rider.isAvailable ? "bg-[#15803D]" : "bg-[#803515]"
              } p-[8px] gap-2 rounded-[24px] w-[98px] h-[32px]`}
            >
              <EyeOffIcon className="w-6 h-6 text-[#FFFFFF]" />
              <p className="m-0 text-[#FFFFFF]">{rider.isAvailable ? "Online" : "Offline"}</p>
            </div>
          </div>
        </div>
        <div className="flex w-full justify-center">
          {rider.isAvailable && isOrderAvailable ? (
            // Renderiza los detalles de la orden si hay una orden no aceptada en el estado y el rider está disponible
            <div className="relative bg-[#FFFFFF] w-full flex flex-col gap-[24px] p-[16px] rounded-[12px] border border-solid border-[#E5E7EB]">
              <button className="absolute top-2 right-2 text-[#9CA3AF] hover:text-red-600" onClick={handleCloseClick}>
                <XIcon className="w-6 h-6" />
              </button>
              <h2 className="text-[16px] m-0 font-bold">New Order</h2>
              <div className="flex justify-between items-center">
                <div>
                  <p className="m-0 text-[#9CA3AF] text-[12px]">Earnings</p>
                  <p className="m-0 text-[#D76C45] text-[21px]">${orderFromState?.deliveryFee}.00 USDC</p>
                </div>
                <div className="w-[84px] h-[38px] bg-[#DCFCE7] flex items-center justify-center text-[#15803D] rounded-[8px]">
                  <span>Placed</span>
                </div>
              </div>
              <div className="flex justify-between">
                <div className="flex gap-[10px] items-center">
                  <div className="w-[50px] h-[50px] bg-[#D13A27] rounded-full p-4 flex items-center justify-center">
                    <img src={orderFromState?.restaurantImage} alt={orderFromState.restaurant} className="" />
                  </div>
                  <p className="m-0">{orderFromState?.restaurant}</p>
                </div>
                <p>0.5 Km</p>
              </div>

              <div className="flex justify-between">
                <div className="flex gap-[10px] items-center">
                  <div className="w-[50px] h-[50px] bg-[#D13A27] rounded-full p-4 flex items-center justify-center">
                    <img src={orderFromState?.restaurantImage} alt={orderFromState.restaurant} className="" />
                  </div>
                  <div>
                    <p className="m-0">Jesús A</p>
                    <p className="m-0 text-[#9CA3AF] text-[12px]">{orderFromState?.address}</p>
                  </div>
                </div>
                <p>4.5 Km</p>
              </div>

              <div className="flex w-full items-center justify-center">
                <div className="flex max-w-[350px] w-full h-[57px] bg-[#D76C45] justify-center rounded-[20px]">
                  <button
                    className="text-[18px} text-[#FFFFFF]"
                    onClick={() => {
                      takeOrder();
                    }}
                  >
                    Accept order
                  </button>
                </div>
              </div>
            </div>
          ) : orderAccepted ? (
            // Renderiza la orden aceptada
            <div className="bg-[#FFFFFF] p-[16px] rounded-[12px] border border-solid border-[#E5E7EB]">
              <h2 className="text-[16px] m-0 font-bold">Order Accepted</h2>
              <p>Order ID: {orderFromState?.id}</p>
              <p>Total Earnings: ${orderFromState?.deliveryFee}.00 USDC</p>
            </div>
          ) : (
            <div className="h-[69px] flex items-center justify-center rounded-full w-[69px] bg-[#15803D]">
              <button
                className="text-[#FFFFFF] font-bold text-[21px] rounded-full border border-solid border-[#FFFFFF] h-[45px] w-[45px] flex items-center justify-center"
                onClick={handleGoClick}
              >
                {rider.isAvailable ? "Wait" : "GO"}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Delivering;
