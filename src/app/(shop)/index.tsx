import { ActivityIndicator, FlatList, StyleSheet, Text, View } from 'react-native'
import React from 'react'
import { PRODUCTS } from '../../../assets/products'
import ProductListItem from '../../components/product-list-item'
import ListHeader from '../../components/list-header'
import { useAuth } from '../../providers/auth-provider'
import { getProducsAndCategories } from '../../api/api'


const Home = () => {
 

  const {data,error,isLoading} = getProducsAndCategories();
  
  if(isLoading){
    return <ActivityIndicator/>
  }

  if(error || !data){
    return <Text> Error  {error?.message || 'An error occured'} </Text>
  }
  console.log(data,"hai bhai");
  
  
  return (

    <View>
      <FlatList  data={data.products} renderItem={({item})=> <ProductListItem product={item}/> } 
      keyExtractor={item => item.id.toString()}
      numColumns={2}
      ListHeaderComponent={<ListHeader categories={data.categories}/>}
      contentContainerStyle= {styles.flatListContent}
      columnWrapperStyle = {styles.flatListColumn}
      style = {
        {
          paddingHorizontal: 10,
          paddingVertical: 5
        }
      }
      />
    </View>
  )
}

export default Home

const styles = StyleSheet.create({
  flatListContent:{
    paddingBottom: 20
  },
  flatListColumn: {
    justifyContent: "space-between"
  }
})