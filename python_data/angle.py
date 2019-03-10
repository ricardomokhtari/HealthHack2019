import matplotlib.pyplot as plt
import math

data = open('nod.txt', 'r')

def clean_up(data):
    data_list = []
    t = 0
    for x in data:
        try:
            int(x[-2])
            triple_list = [y.strip() for y in x.split(',')]
            x = float(triple_list[0])
            y = float(triple_list[1])
            z = float(triple_list[2])
            data_list.append((t, x,y,z))
            t += 1
        except:
            pass
    return data_list

data_list = clean_up(data)

def angle(x, y, z):
    #Neck flexion angle
    square_sum = math.sqrt(y**2 + z**2)
    divide = x/square_sum
    angle_rad = math.atan(divide)
    angle = -math.degrees(angle_rad)
    return(angle)


t = []
angle_data = []
for item in data_list:
    t.append(item[0])
    angle_data.append(angle(item[2], item[1], item[3]))

plt.scatter(t, angle_data, label= "1st", color= "green",
            marker= "*", s=30)

plt.title('Neck Flexion Angle Estimation')
plt.show()
