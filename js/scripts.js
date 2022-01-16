const libsList = document.querySelector('#libs-list')
const libsFile = '../data/libs.json'
const programsList = document.querySelector('#programs-list')
const programsFile = '../data/programs.json'

const addScripts = (objects, type) => {
    const template = document.querySelector('#scriptTemplate')
    let scriptNames = Object.keys(objects)
    for (let i = 0; i < scriptNames.length; ++i) {
        let listContainer
        if (type === 'libs') {
            listContainer = libsList
        } else {
            listContainer = programsList
        }
        let tmpElement = template.content.cloneNode(true)
        let tmpObject = objects[scriptNames[i]]
        
        tmpElement.querySelector('.code-example-tmpl').innerHTML = 'dpm install ' + tmpObject['install']
        tmpElement.querySelector('.name-tmpl').innerHTML = tmpObject['name']

        tmpElement.querySelector('.author-tmpl a').href = tmpObject['author_url']
        tmpElement.querySelector('.author-tmpl a').innerHTML = tmpObject['author']
        tmpElement.querySelector('.author-tmpl').innerHTML = 'by ' + tmpElement.querySelector('.author-tmpl').innerHTML
        
        tmpElement.querySelector('.description-tmpl').innerHTML = tmpObject['description']
        
        if (tmpObject['example'] !== '') {
            tmpElement.querySelector('.example-program-tmpl').innerHTML = 'Install example program: ' + tmpElement.querySelector('.example-program-tmpl').innerHTML
            tmpElement.querySelector('.example-program-install').innerHTML = 'dpm get ' + tmpObject['example']
        } else {
            tmpElement.removeChild(tmpElement.querySelector('.example-program-tmpl'))
        }
        
        listContainer.appendChild(tmpElement)
    }
}

const fetchJson = async (url, type) => {
    try {
        const data = await fetch(url);
        const response = await data.json();
        addScripts(response, type)
    } catch (error) {
        console.log(error);
    }
};

fetchJson(libsFile, 'libs')
fetchJson(programsFile, 'programs')