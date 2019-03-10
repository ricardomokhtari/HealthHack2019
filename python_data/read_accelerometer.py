import csv
import matplotlib.pyplot as plt

data = open('testmovement.txt', 'r')

def clean_up(data):
    data_list = []
    t = 0
    for x in data:
        try:
            int(x[-2])
            print(x)
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

# with open('test_output.csv', "w") as csv_file:
#     csv_writer = csv.writer(csv_file)
#     for element in data_list:
#         csv_writer.writerow(element)

t = []
x = []
y = []
z = []
for item in data_list:
    t.append(item[0])
    x.append(item[1])
    y.append(item[2])
    z.append(item[3])

plt.scatter(t, x, label= "1st", color= "green",
            marker= "*", s=30)
plt.scatter(t, y, label= "2nd", color= "red",
            marker= "o", s=30)
plt.scatter(t, z, label= "3rd", color= "blue",
            marker= "^", s=30)
plt.legend()
plt.title('straight-hunch-straight')
plt.show()
