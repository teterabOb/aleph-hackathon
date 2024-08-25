"use client";

import React, { useEffect, useRef, useState } from "react";
import { RootState } from "../../store/store";
import { GoogleMap, Libraries, Marker, useLoadScript } from "@react-google-maps/api";
import { MapPinIcon } from "lucide-react";
import type { NextPage } from "next";
import { useSelector } from "react-redux";
import { useAccount } from "wagmi";
import { Address } from "~~/components/scaffold-eth";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth/useScaffoldWriteContract";

const libraries: Libraries = ["places"];
const idProject: string = process.env.ID_PROJECT || "";

const FinishOrder: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const mapRef = useRef<google.maps.Map | null>(null);
  const mapContainerStyle: React.CSSProperties = {
    width: "100vw",
    height: "100vh",
    position: "absolute" as const,
    top: 0,
    left: 0,
    zIndex: -1,
  };
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("DispatchEcho");

  const finishOrder = async () => {
    try {
      await writeYourContractAsync({
        functionName: "sendMessageMockUp",
        args: [
          "0x1234567890123456789012345678901234567890",
          BigInt(idProject),
          "0x1234567890123456789012345678901234567890",
          BigInt(1000),
          BigInt(0),
        ],
      });
    } catch (e) {
      console.error("Error setting greeting:", e);
    }
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
  return (
    <div className="relative w-full h-full min-h-screen">
      {isLoaded && (
        <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={15} onLoad={onLoad}>
          <Marker position={center} />
        </GoogleMap>
      )}
      <div className="bg-[#FFFFFF] p-[16px] rounded-[12px] border border-solid border-[#E5E7EB] m-[20px]">
        <h2 className="text-[16px] text-center m-0 font-bold">Finish transaction</h2>
        <div>
          <p>Shipment #</p>
          <Address address={connectedAddress} />
        </div>
        <div>
          <p>Est. Delivery</p>
          <p>09:58 am</p>
        </div>
      </div>
      <div className="flex w-full items-center justify-center">
        <div className="flex max-w-[350px] w-full h-[57px] bg-[#D76C45] justify-center rounded-[20px]">
          <button
            onClick={() => {
              finishOrder();
            }}
            className="text-[18px} text-[#FFFFFF]"
          >
            Finish
          </button>
        </div>
      </div>
    </div>
  );
};

export default FinishOrder;
