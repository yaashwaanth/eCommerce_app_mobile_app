import { ActivityIndicator, FlatList, Image, Pressable, StyleSheet, Text, View } from 'react-native'
import React, { useState } from 'react'
import { Redirect, Stack, useLocalSearchParams } from 'expo-router'
import { getMyOrder } from '../../../api/api';
// import { ORDERS } from '../../../../assets/orders';


const orderDetails = () => {
    const {slug} = useLocalSearchParams<{slug: string}>();
    // const order = ORDERS.find(order=> order.slug === slug);
    const {data: order,error,isLoading} = getMyOrder(slug); 

    if(isLoading) return <ActivityIndicator/>

    if(error || !order) return <Text>Error : { error?.message}</Text>

    const orderItems = order.order_items.map((orderItem:any)=>{
      return {
        id: orderItem.id,
        title: orderItem.products.title,
        heroImage: orderItem.products.heroImage,
        price: orderItem.products.price,
        quantity: orderItem.quantity
      }
    } )
  return (
    <View style={styles.container}>
       <Stack.Screen options={{title: `${order.slug}`}}/>

      <Text style={styles.item}>{order.slug}</Text>
      <Text style={styles.details}>{order.description}</Text>
      <View style={[styles.statusBadge,styles[`statusBadge_${order.status}`]]}>
        <Text style={styles.statusText}>{order.status}</Text>
      </View>
      <Text style={styles.date}>{order.created_at}</Text>
      <Text style={styles.itemsTitle}>Items Ordered:</Text>
      <FlatList
      data={orderItems}
      keyExtractor={item=> item.id.toString()}
      renderItem = {({item})=> (
       <Pressable onPress={()=>setDrop(prev=>!prev)}>
         <View style={styles.orderItem}>
            <Image source={{uri: item.heroImage}} style={styles.heroImage}/>
            <View style={styles.itemInfo}>
                <Text style={styles.itemInfo}>{item.title}</Text>
                <Text style={styles.itemPrice}>Price : ${item.price}</Text>
            </View>
            
        </View>
       </Pressable>
        )}
      />


    </View>
  )
}

export default orderDetails

const styles: {[key: string]: any} = StyleSheet.create({
    container: {
        flex: 1,
        padding: 16,
        backgroundColor: '#fff',
      },
      item: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 8,
      },
      details: {
        fontSize: 16,
        marginBottom: 16,
      },
      statusBadge: {
        padding: 8,
        borderRadius: 4,
        alignSelf: 'flex-start',
      },
      statusBadge_Pending: {
        backgroundColor: 'orange',
      },
      statusBadge_Completed: {
        backgroundColor: 'green',
      },
      statusBadge_Shipped: {
        backgroundColor: 'blue',
      },
      statusBadge_InTransit: {
        backgroundColor: 'purple',
      },
      statusText: {
        color: '#fff',
        fontWeight: 'bold',
      },
      date: {
        fontSize: 14,
        color: '#555',
        marginTop: 16,
      },
      itemsTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        marginTop: 16,
        marginBottom: 8,
      },
      orderItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: 8,
        padding: 16,
        backgroundColor: '#f8f8f8',
        borderRadius: 8,
      },
      heroImage: {
        width: '50%',
        height: 100,
        borderRadius: 10,
      },
      itemInfo: {},
      itemName: {
        fontSize: 16,
        fontWeight: 'bold',
      },
      itemPrice: {
        fontSize: 14,
        marginTop: 4,
      },
})