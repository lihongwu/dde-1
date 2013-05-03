#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#Author:      yuanjq <yuanjq91@gmail.com>

class Weather
    weather_data = null
    prov2city = null
    xhr = null 
    cityurl = null
    cityid = null
    cityid_info = null
    weather_now_pic = null 
    temperature_now = null 
    city = null
    date = null
    i_week = 0
    week_n = null
    week_name = null
    pic1 = null
    pic2 = null
    pic3 = null 
    pic4 = null 
    pic5 = null
    pic6 = null 
    tempratue1 = null
    tempratue2 = null
    tempratue3 = null
    tempratue4 = null
    tempratue5 = null
    tempratue6 = null
    refresh = null
    weather_click_times = 0
    auto_update = null #set it as whole  for we can close auto update in needing
    img_url_first = "desktop_plugin/weather/img/"

    constructor: ->

        @element = document.createElement('div')
        @element.setAttribute('class', "Weather")
        @element.draggable = true
        @weathergui_init()
        
        weather_now = create_element("div", "weather_now", @element)
        weather_now.style.position = "absolute"
        weather_now.style.top = "7px" #10
        weather_now.style.left = "20px"
        weather_now_pic = create_element("img", null, weather_now)
        weather_now_pic.src = img_url_first + weather_data.weatherinfo.img1 + ".png"
        weather_now_pic.style.width = "50px"
        weather_now_pic.style.height = "50px"
        weather_now_pic.draggable = false

        temperature_now = create_element("div", "temperature_now", @element)
        temperature_now.style.position = "absolute"
        temperature_now.style.top = "25px"
        temperature_now.style.left = "90px"
        temp_str = weather_data.weatherinfo.temp1
        i = temp_str.indexOf("℃")
        j = temp_str.lastIndexOf("℃")
        temper= ( parseInt(temp_str.substring(0,i)) + parseInt(temp_str.substring(i+2,j)) )/2
        temperature_now.textContent = temper + "°"
        temperature_now.style.width = "50px"
        temperature_now.style.height = "50px"
        temperature_now.style.fontSize = "30px"
        # temperature_now.style.fontWeight = "bold"
        temperature_now.style.color = "deepskyblue"

        city_and_date = create_element("div", "city_and_date", @element)
        city_and_date.style.position = "absolute"
        city_and_date.style.top = "15px"
        city_and_date.style.left = "150px"
        city = create_element("div", "city", city_and_date)
        city.textContent = weather_data.weatherinfo.city
        city.style.position = "relative"
        city.style.left = "5px"       
        city.style.color = "deepskyblue" 
        week_name = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        date = create_element("div", "date", city_and_date)
        date.style.color = "deepskyblue"
        # date.style.top = "15px"
        date.textContent =  weather_data.weatherinfo.date_y + weather_data.weatherinfo.week

        more_weather_menu = create_element("div", "more_weather_menu", @element)
        more_weather_menu.style.position = "absolute"
        more_weather_menu.style.left = "110px"
        more_weather_menu.style.top = "65px"
        more_weather_menu.style.width = "175px"
        more_weather_menu.style.display = "none"
        # more_weather_menu.style.Opacity = 50;

        first_day_weather_data = create_element("div", null, more_weather_menu)
        first_day_weather_data.style.backgroundColor = "palegoldenrod"
        first_day_weather_data.style.opacity = 0.6

        week = create_element("a", null, first_day_weather_data)
        week.textContent = week_name[(week_n)%7]
        pic1 = create_element("img", null, first_day_weather_data)
        pic1.src = img_url_first + weather_data.weatherinfo.img1 + ".png"
        pic1.style.width = "30px"
        pic1.style.height = "30px"

        tempratue1 = create_element("a", null, first_day_weather_data)
        tempratue1.textContent = weather_data.weatherinfo.temp1

        second_day_weather_data = create_element("div", null, more_weather_menu)
        second_day_weather_data.style.backgroundColor = "deepskyblue"
        second_day_weather_data.style.opacity = 0.6

        week = create_element("a", null, second_day_weather_data)
        week.textContent = week_name[(week_n+1)%7]
        pic2 = create_element("img", null, second_day_weather_data)
        pic2.src = img_url_first + weather_data.weatherinfo.img3 + ".png"
        pic2.style.width = "30px"
        pic2.style.height = "30px"

        tempratue2 = create_element("a", null, second_day_weather_data)
        tempratue2.textContent = weather_data.weatherinfo.temp2

        third_day_weather_data = create_element("div", null, more_weather_menu)
        third_day_weather_data.style.backgroundColor = "palegoldenrod"
        third_day_weather_data.style.opacity = 0.6
        week = create_element("a", null, third_day_weather_data)
        week.textContent = week_name[(week_n+2)%7]
        pic3 = create_element("img", null, third_day_weather_data)
        pic3.src = img_url_first + weather_data.weatherinfo.img5 + ".png"
        pic3.style.width = "30px"
        pic3.style.height = "30px"
        tempratue3 = create_element("a", null, third_day_weather_data)
        tempratue3.textContent = weather_data.weatherinfo.temp3


        fourth_day_weather_data = create_element("div", null, more_weather_menu)
        fourth_day_weather_data.style.backgroundColor = "deepskyblue"
        fourth_day_weather_data.style.opacity = 0.6

        week = create_element("a", null, fourth_day_weather_data)
        week.textContent = week_name[(week_n+3)%7]
        pic4 = create_element("img", null, fourth_day_weather_data)
        pic4.src = img_url_first + weather_data.weatherinfo.img7 + ".png"
        pic4.style.width = "30px"
        pic4.style.height = "30px"
        tempratue4 = create_element("a", null, fourth_day_weather_data)
        tempratue4.textContent = weather_data.weatherinfo.temp4

        fifth_day_weather_data = create_element("div", null, more_weather_menu)
        fifth_day_weather_data.style.backgroundColor = "palegoldenrod"
        fifth_day_weather_data.style.opacity = 0.6

        week = create_element("a", null, fifth_day_weather_data)
        week.textContent = week_name[(week_n+4)%7]
        pic5 = create_element("img", null, fifth_day_weather_data)
        pic5.src = img_url_first + weather_data.weatherinfo.img9 + ".png"
        pic5.style.width = "30px"
        pic5.style.height = "30px"
        tempratue5 = create_element("a", null, fifth_day_weather_data)
        tempratue5.textContent = weather_data.weatherinfo.temp5

        sixth_day_weather_data = create_element("div", null, more_weather_menu)
        sixth_day_weather_data.style.backgroundColor = "deepskyblue"
        sixth_day_weather_data.style.opacity = 0.6

        week = create_element("a", null, sixth_day_weather_data)
        week.textContent = week_name[(week_n+5)%7]
        pic6 = create_element("img", null, sixth_day_weather_data)
        pic6.src = img_url_first + weather_data.weatherinfo.img11 + ".png"
        pic6.style.width = "30px"
        pic6.style.height = "30px"
        tempratue6 = create_element("a", null, sixth_day_weather_data)
        tempratue6.textContent = weather_data.weatherinfo.temp6

        refresh = create_element("img", null, @element)
        refresh.draggable = false  
        refresh.style.position = "absolute"
        refresh.style.top = "12px"
        refresh.style.left = "215px"   
        refresh.src = img_url_first + "refresh.png"
        refresh.style.width = "20px"
        refresh.style.height = "20px"

        more_city = create_element("img", null, @element)
        more_city.draggable = false  
        more_city.style.position = "relative"
        more_city.style.top = "15px"
        more_city.style.left = "190px"      
        more_city.src = img_url_first + "ar.png"
       
        more_city_menu = create_element("div", "more_city_menu", @element)
        more_city_menu.style.display = "none"
        # more_city_menu.style.position = "relative"
        # more_city_menu.style.top = "17px"
        # more_city_menu.style.left = "170px"        

        u1 = create_element("div", null, more_city_menu)        
        l1 = create_element("div", null, u1)
        l2 = create_element("div", null, u1)
        l3 = create_element("div", null, u1)
        a1 = create_element("div", null, l1)
        a1.innerText = "北京"
        a2 = create_element("div", null, l2)
        a2.innerText = "上海"
        a3 = create_element("div", null, l3)
        a3.innerText = "广东"       

        date.addEventListener("click", => 
            if more_weather_menu.style.display == "none" 
                more_weather_menu.style.display = "block"
                more_city_menu.style.display = "none"
                @element.style.zIndex = "65535"    
                echo "more_weather_menu block ,none more_city none  "        
            else 
                more_weather_menu.style.display = "none"
                more_city_menu.style.display = "none"
                @element.style.zIndex = "1"
                echo "more_weather_menu none ,none more_city none  "   
        )        

        more_city.addEventListener("click", =>             
            if more_city_menu.style.display == "none"
                more_city_menu.style.display = "block"
                more_weather_menu.style.display = "none"
                @element.style.zIndex = "65535"
                echo "more_city block , more_weather_menu none "
            else 
                more_city_menu.style.display = "none" 
                more_weather_menu.style.display = "none"
                @element.style.zIndex = "1"
                echo "more_city none , more_weather_menu none "
        )

        refresh.addEventListener("click", =>
            refresh.style.backgroundColor = "gray"
            @weathergui_update()
            # refresh.style.backgroundColor = null
        )

        @element.addEventListener("click", =>
            weather_click_times++
            if weather_click_times%2
                @element.style.zIndex = "65535"
            else 
                @element.style.zIndex = "1"
        )   

    ajax : (url, method, callback, asyn=true) ->
        xhr = new XMLHttpRequest()
        xhr.open(method, url, asyn)
        xhr.send(null)
        xhr.onreadystatechange = ->
            if (xhr.readyState == 4 and xhr.status == 200)
                echo "received all over 200 update"
                callback?(xhr)                
            else if xhr.readystate == 0 
                echo "init"
            else if xhr.readystate == 1
                echo "open"
            else if xhr.readystate == 2
                echo "send"
            else if xhr.readystate == 3
                echo "receiving"
    

    weathergui_init: =>

        cityid = 101010100 #101200101
        cityurl = "http://m.weather.com.cn/data/"+cityid+".html"
        # echo "weathergui_init start"
        @date_init()
        # here set ten mins to updata gui
        auto_update = setInterval(@weathergui_update(),10*60000)
        # echo "weathergui_init over"


    weathergui_update: ->        
        # echo "weathergui_update"
        @ajax( cityurl , "GET", (xhr)=>
            localStorage.setItem(weather_data,xhr.responseText)
            weather_data = JSON.parse(localStorage.getItem(weather_data))
            # localStorage.removeItem(info)  
            # echo "received all update "
            while i_week < week_name.length
                break if weather_data.weatherinfo.week is week_name[i_week]
                i_week++
            # alert i_week  
            week_n = i_week
            weather_now_pic.src = img_url_first + weather_data.weatherinfo.img1 + ".png"
            str_data = weather_data.weatherinfo.date_y
            date.textContent = str_data.substring(0,str_data.indexOf("年")) + "." + str_data.substring(str_data.indexOf("年")+1,str_data.indexOf("月"))+ "." + str_data.substring(str_data.indexOf("月") + 1,str_data.indexOf("日")) + weather_data.weatherinfo.week            
            temp_str = weather_data.weatherinfo.temp1
            i = temp_str.indexOf("℃")
            j = temp_str.lastIndexOf("℃")
            temper= ( parseInt(temp_str.substring(0,i)) + parseInt(temp_str.substring(i+2,j)) )/2
            temperature_now.textContent = temper + "°"            
            city.textContent = weather_data.weatherinfo.city
            pic1.src = img_url_first + weather_data.weatherinfo.img1 + ".png"
            tempratue1.textContent = weather_data.weatherinfo.temp1
            pic2.src = img_url_first + weather_data.weatherinfo.img3 + ".png"
            tempratue2.textContent = weather_data.weatherinfo.temp2
            pic3.src = img_url_first + weather_data.weatherinfo.img5 + ".png"
            tempratue3.textContent = weather_data.weatherinfo.temp3
            pic4.src = img_url_first + weather_data.weatherinfo.img7 + ".png"
            tempratue4.textContent = weather_data.weatherinfo.temp4
            pic5.src = img_url_first + weather_data.weatherinfo.img9 + ".png"
            tempratue5.textContent = weather_data.weatherinfo.temp5
            pic6.src = img_url_first + weather_data.weatherinfo.img11 + ".png"
            tempratue6.textContent = weather_data.weatherinfo.temp6

            refresh.style.backgroundColor = null
        )
              

    date_init: ->        
        # echo "weathergui_receiving"
        #here tip the user "data receiving......"" 
        weather_data= {
            "weatherinfo": {
                "city": "......",
                "city_en": "......",
                "date_y": "正在加载中...",
                "date": "",
                "week": "...",
                "fchh": "11",
                "cityid": "101010100",
                "temp1": "16℃~8℃",
                "temp2": "22℃~10℃",
                "temp3": "24℃~10℃",
                "temp4": "25℃~12℃",
                "temp5": "27℃~13℃",
                "temp6": "23℃~12℃",
                "tempF1": "60.8℉~46.4℉",
                "tempF2": "71.6℉~50℉",
                "tempF3": "75.2℉~50℉",
                "tempF4": "77℉~53.6℉",
                "tempF5": "80.6℉~55.4℉",
                "tempF6": "73.4℉~53.6℉",
                "weather1": "阵雨转晴",
                "weather2": "晴",
                "weather3": "晴",
                "weather4": "晴转多云",
                "weather5": "多云",
                "weather6": "多云转阴",
                "img1": "3",
                "img2": "0",
                "img3": "0",
                "img4": "99",
                "img5": "0",
                "img6": "99",
                "img7": "0",
                "img8": "1",
                "img9": "1",
                "img10": "99",
                "img11": "1",
                "img12": "2"
              }
            }
        prov2city = {
        '请选择省份':['请选择城市'],
        '北京':['北京'],
        '上海':['上海'],
        '黑龙江':['牡丹江','大兴安岭','黑河','齐齐哈尔','绥化','鹤岗','佳木斯','伊春','双鸭山','哈尔滨','鸡西','漠河','大庆','七台河','绥芬河'],
        '安徽':['淮南','马鞍山','淮北','铜陵','滁州','巢湖','池州','宣城','亳州','宿州','阜阳','六安','蚌埠','合肥','芜湖','安庆','黄山'],
        '澳门':['澳门'],
        
        '重庆':['奉节','重庆','涪陵'],
        '福建':['莆田','浦城','南平','宁德','福州','龙岩','三明','泉州','漳州','厦门'],
        '甘肃':['张掖','金昌','武威','兰州','白银','定西','平凉','庆阳','甘南','临夏','天水','嘉峪关','酒泉','陇南'],
        '广东':['南雄','韶关','清远','梅州','肇庆','广州','河源','汕头','深圳','汕尾','湛江','阳江','茂名','佛冈','梅县','电白','高要','珠海','佛山','江门','惠州','东莞','中山','潮州','揭阳','云浮'],
        '广西':['桂林','河池','柳州','百色','贵港','梧州','南宁','钦州','北海','防城港','玉林','贺州','来宾','崇左'],
        '贵州':['毕节','遵义','铜仁','安顺','贵阳','黔西南布依族苗族自治州','六盘水'],
        '海南':['海口','三亚','屯昌','琼海','儋州','文昌','万宁','东方','澄迈','定安','临高','白沙黎族自治县','乐东黎族自治县','陵水黎族自治县','保亭黎族苗族自治县','琼中黎族苗族自治县'],
        '河北':['邯郸','衡水','石家庄','邢台','张家口','承德','秦皇岛','廊坊','唐山','保定','沧州'],
        '河南':['安阳','三门峡','郑州','南阳','周口','驻马店','信阳','开封','洛阳','平顶山','焦作','鹤壁','新乡','濮阳','许昌','漯河','商丘','济源'],
        
        '湖北':['襄樊','荆门','黄冈','恩施土家族苗族自治州','武汉','麻城','黄石','鄂州','孝感','咸宁','随州','仙桃','天门','潜江','神农架','枣阳'],
        '湖南':['张家界','岳阳','怀化','长沙','邵阳','益阳','郴州','桑植','沅陵','南岳','株洲','湘潭','衡阳','娄底','常德'],
        '吉林':['辽源','通化','白城','松原','长春','吉林市','桦甸','延边朝鲜族自治州','集安','白山','四平'],
        '江苏':['无锡','苏州','盱眙','赣榆','东台','高邮','镇江','泰州','宿迁','徐州','连云港','淮安','南京','扬州','盐城','南通','常州'],
        '江西':['庐山','玉山','贵溪','广昌','萍乡','新余','宜春','赣州','九江','景德镇','南昌','鹰潭','上饶','抚州'],
        '辽宁':['葫芦岛','盘锦','辽阳','铁岭','阜新','朝阳','锦州','鞍山','沈阳','本溪','抚顺','营口','丹东','瓦房店','大连'],
        '内蒙古':['呼伦贝尔','兴安盟','锡林郭勒盟','巴彦淖尔盟','包头','呼和浩特','锡林浩特','通辽','赤峰','乌海','鄂尔多斯','乌兰察布盟'],
        '宁夏':['石嘴山','银川','吴忠','固原'],
        '青海':['海北藏族自治州','海南藏族自治州','西宁','玉树藏族自治州','黄南藏族自治州','果洛藏族自治州','海西蒙古族藏族自治州','海东'],
        '山东':['德州','滨州','烟台','聊城','济南','泰安','淄博','潍坊','青岛','济宁','日照','泰山','枣庄','东营','威海','莱芜','临沂','菏泽'],
        '山西':['长治','晋中','朔州','大同','吕梁','忻州','太原','阳泉','临汾','运城','晋城','五台山'],
        '陕西':['榆林','延安','西安','渭南','汉中','商洛','安康','铜川','宝鸡','咸阳'],
        
        '四川':['甘孜藏族自治州','阿坝藏族羌族自治州','成都','绵阳','雅安','峨眉山','乐山','宜宾','巴中','达州','遂宁','南充','泸州','自贡','攀枝花','德阳','广元','内江','广安','眉山','资阳','凉山彝族自治州'],
        '台湾':['台北'],
        '天津':['天津','塘沽区'],
        '西藏':['那曲','日喀则','拉萨','山南','阿里','昌都','林芝'],
        '香港':['香港'],
        '新疆':['昌吉回族自治州','克孜勒苏柯尔克孜自治州','伊犁哈萨克自治州','阿拉尔','克拉玛依','博尔塔拉蒙古自治州','乌鲁木齐','吐鲁番','阿克苏','石河子','喀什','和田','哈密','奇台'],
        '云南':['昭通','丽江','曲靖','保山','大理白族自治州','楚雄彝族自治州','昆明','瑞丽','玉溪','临沧','思茅','红河哈尼族彝族自治州','文山壮族苗族自治州','西双版纳傣族自治州','德宏傣族景颇族自治州','怒江傈傈族自治州','迪庆藏族自治州'],
        '浙江':['湖州','嵊州','平湖','石浦','宁海','洞头','舟山','杭州','嘉兴','金华','绍兴','宁波','衢州','丽水','台州','温州']
        }
