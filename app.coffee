Array::indexOf or= (item) ->
  for x, i in this
    return i if x is item
  return -1

data = JSON.parse Utils.domLoadDataSync "data/data.json"

gutter = 20
padding = 16
count = data.buckets.length
boxSize = (Screen.width-3*padding)/2
focusedBoxWidth = Screen.width-4*padding
focusedBoxHeight = 200	

# scroll = new ScrollComponent
# 	height: Screen.height
# 	width : Screen.width
	

class Bucket extends Layer
	constructor: (@options={}) ->
		@options.width ?= boxSize
		@options.height ?= boxSize
		@options.borderRadius ?= "16px"
		@options.scrollHorizontal = true
		
		@label = new TextLayer
			fontSize: 16
			color: "rgba(255,255,255,1)"
		@thumbnail = new Layer
			width: @options.width*0.6
			height: @options.height*0.6
		
		super @options
				
		@thumbnail.parent = @
		@thumbnail.centerX()
		@thumbnail.y = 16
		@label.parent = @
		@label.centerX()
		@label.textAlign = "center"
		@label.width = @thumbnail.width
		@label.autoHeight = yes
		@label.y = @thumbnail.y + @thumbnail.height + 16
		
		@states =
			default:
				height: @options.height
				width: @options.width
				x: @options.x
				y: @options.y
			active:	
				height: focusedBoxHeight
				width: focusedBoxWidth
				x: 2*padding
				y: padding
				animationOptions: 
					curve: Bezier.ease
					time: 0.1
						
		@.onClick ->
			if @.state == "active"
				for bucketBox in bucketBoxes
					bucketBox.states.switch "default"
					bucketBox.state = "default"
				scroll.scrollHorizontal = false
				scroll.scrollVertical = true
				bucketsCont.width = Screen.width
				for tagLayer in tagsContainer.content.subLayers
					tagLayer.destroy()
				tagsContainer.visible = false
			else
				@.states.switchInstant "active"
				@.state = "active"
				scroll.scrollHorizontal = true
				scroll.scrollVertical = false
				activeIndex = bucketBoxes.indexOf(@)
				for tagObject, index in @.tags
					tagLayer = comp_tag.copy()
					tagLayer.parent = tagsContainer.content
					tagLayer.originX = 0
					tagLayer.scale = 1.3
					tagLayer.x = tagsContainer.frame.x
					tagLayer.y = index*(tagLayer.height + padding)
					tag_name.text = tagObject.name
					tag_trend.text = tagObject.trend	
				tagsContainer.visible = true
				for inActiveBucketBox, index in bucketBoxes
					if index < activeIndex
						inActiveBucketBox.states.inactive =
							height: focusedBoxHeight
							width: focusedBoxWidth
							x: @.x - (activeIndex - index)*(padding + focusedBoxWidth) 
							y: padding
							animationOptions: 
								curve: Bezier.ease
								time: 0.1
						inActiveBucketBox.states.switch "inactive"
						inActiveBucketBox.state = "inactive"
					else if index > activeIndex
						inActiveBucketBox.states.inactive =
							height: focusedBoxHeight
							width: focusedBoxWidth
							x: @.x + (index - activeIndex)*(padding + focusedBoxWidth) 
							y: padding
							animationOptions: 
								curve: Bezier.ease
								time: 0.1
						inActiveBucketBox.states.switch "inactive"
						inActiveBucketBox.state = "inactive"	
					else 
						inActiveBucketBox.states.switch "active"
						inActiveBucketBox.state = "active"	
						
bucketBoxes = []

bucketsCont = new Layer
	width: count*(focusedBoxWidth+1.2*padding)
	height: (count/2)*(boxSize+padding) + padding
	backgroundColor: "#ffffff"
	parent : screen_1
	
scroll = ScrollComponent.wrap(bucketsCont)
scroll.scrollHorizontal = false
scroll.content.clip = false
scroll.directionLock = true
scroll.backgroundColor = "rgba(255,255,255,0)"
scroll.mouseWheelEnabled = true

tagsContainer = new ScrollComponent
	width: Screen.width
	height: Screen.height - 2*padding - focusedBoxHeight
	centerX: screen_1.centerX
	y: 2*padding + focusedBoxHeight
	backgroundColor: "#fffff"
tagsContainer.parent = bucketsCont
tagsContainer.scrollHorizontal = false
tagsContainer.backgroundColor = "#fffff"
tagsContainer.mouseWheelEnabled = true
tagsContainer.visible = false
tagsContainer.content.clip = false
tagsContainer.directionLock = true
tagsContainer.contentInset = 
		right: 2*padding
		left: 2.5*padding
	
for bucketObject, index in data.buckets
	bucketBox = new Bucket
	bucketBox.parent = bucketsCont
	bucketBox.width = boxSize
	bucketBox.height = boxSize	
	xPosition = if (index%2 != 0 and index !=0) then bucketBox.width + 2*padding 				else padding
	bucketBox.x = xPosition
	yPosition = padding + (Math.floor(index/2)) *(bucketBox.width+padding)
	bucketBox.y = yPosition 
	bucketBox.states.default =
				height: boxSize
				width: boxSize
				x: xPosition
				y: yPosition
				animationOptions: 
					curve: Bezier.ease
					time: 0.1
	bucketBox.state = "default"			
	bucketBox.backgroundColor = bucketObject.backgroundColor	
	bucketBox.label.text = bucketObject.name
	bucketBox.thumbnail.image = Utils.randomImage()
	bucketBox.tags = bucketObject.tags
	bucketBoxes.push(bucketBox)						