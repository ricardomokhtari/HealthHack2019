import csv
import matplotlib.pyplot as plt

data = open('flex.txt', 'r')

def clean_up(data):
    t = 0
    data_list = []
    for x in data:
        if 'degr' in x:
            space = x.index(' ')
            numb = x[:space]
            flex = float(numb)
            print(flex)
            data_list.append((t, flex))
            t += 1
    return data_list


data_list = clean_up(data)

t = []
x = []
for item in data_list:
    t.append(item[0])
    x.append(item[1])

plt.scatter(t, x, label= "1st", color= "green",
            marker= "*", s=30)
plt.title('Flex - Hunch test 1')
plt.show()
