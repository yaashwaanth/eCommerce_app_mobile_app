import { StyleSheet, Text, View } from 'react-native'
import React from 'react'
import { Link, Stack } from 'expo-router'

const NotFoundScreen = () => {
  return (
    <>
      <Stack.Screen options={{title:"Opps! This screen doesn't exist."}}/>
      <View>
        <Link href='/'>Go to home screen</Link>
      </View>
      
    </>
  )
}

export default NotFoundScreen

const styles = StyleSheet.create({})